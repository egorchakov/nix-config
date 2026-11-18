set default-list
set script-interpreter := ["nu"]
set shell := ["nu", "-c"]
set default-script
set lazy

deploy *ARGS: (rex "prefetch")
    deploy {{ ARGS }} --no-demarcate-output -- --log-format internal-json o+e>| nom --json

deploy-ml *ARGS: (rex "prefetch")
    deploy --groups ml {{ ARGS }}

deploy-kits *ARGS: (rex "prefetch")
    deploy --groups kits {{ ARGS }}

[positional-arguments]
deploy-kits-via BUILDER *KITS: (rex "prefetch")
    def main [builder: string, ...kits: string] {
        let nodes = (nix eval --json .#deploy.nodes
            --apply 'builtins.mapAttrs (_: node: { inherit (node) groups hostname sshUser; })'
            | from json)
        let kit_names = ($nodes | items {|name, node| if 'kits' in $node.groups { $name } } | compact)
        let selected = if ($kits | is-empty) { $kit_names } else { $kits | uniq }
        let unknown = ($selected | where {|kit| $kit not-in $kit_names })
        if not ($unknown | is-empty) { error make { msg: $"Unknown kits: ($unknown | str join ', ')" } }

        let builder_store = $"ssh-ng://($builder)"
        for kit in $selected {
            let node = ($nodes | get $kit)
            let profile = (nix build --eval-store auto --store $builder_store --no-link --print-out-paths
                $".#deploy.nodes.($kit).profiles.home.path" | str trim)
            (ssh -- $builder nix copy --no-check-sigs --to $"ssh-ng://($node.sshUser)@($node.hostname)" $profile)
        }

        deploy --targets ...($selected | each {|kit| $".#($kit).home" })
    }

follow: (rex "prefetch")
    flake-edit --config flake-edit.toml --non-interactive follow

bump-rerun version="stable":
    nix-update --flake --override-filename pkgs/rerun-bin.nix --version="{{ version }}" rerun-bin

rex action="prefetch":
    if "{{ action }}" not-in [prefetch update] { error make { msg: "Expected rex prefetch or rex update" } }
    let lock = open --raw flake.lock | from json
    let inputs = $lock.nodes | get $lock.root | get inputs
    let nixpkgs = $lock.nodes | get $inputs.nixpkgs | get locked
    let netrc = ^nix run $"github:($nixpkgs.owner)/($nixpkgs.repo)/($nixpkgs.rev)#age" -- --decrypt --identity ~/.ssh/id_ed25519 secrets/rex.netrc.age | complete
    if $netrc.exit_code != 0 { error make { msg: $"Could not decrypt Rex credentials:\n($netrc.stderr)" } }
    if "{{ action }}" == "update" {
        $netrc.stdout | ^nix flake update rex --option netrc-file /dev/stdin
    } else {
        let rex = $lock.nodes | get $inputs.rex | get locked
        $netrc.stdout | ^nix flake prefetch $"($rex.url)?narHash=($rex.narHash)" --option netrc-file /dev/stdin
    }
