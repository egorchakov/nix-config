set default-list
set script-interpreter := ["nu"]
set shell := ["nu", "-c"]
set default-script
set lazy

deploy *ARGS: (rex "prefetch")
    deploy {{ ARGS }} --no-demarcate-output -- --log-format internal-json o+e>| rom

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
            (ssh -- $builder env
                '"NIX_SSHOPTS=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null"'
                nix copy --no-check-sigs --to $"ssh-ng://($node.sshUser)@($node.hostname)" $profile)
        }

        deploy --targets ...($selected | each {|kit| $".#($kit).home" })
    }

[positional-arguments]
update *ARGS:
    def --wrapped main [...args: string] {
        let lock = '.tack/pins.lock.json'
        let previous = open --raw $lock
        let report = with-env { GH_TOKEN: (^gh auth token --hostname github.com) } {
            ^tack update --exclude rex ...$args
        }
        print $report
        if (open --raw $lock) != $previous {
            let body = $report | lines | where { $in =~ ' -> |relocked \(--accept\)' } | str join (char nl)
            ^git commit --only -m 'chore: update tack pins' -m $body -- $lock .tack/default.nix
        }
    }

bump-rerun version="stable":
    nix-update --flake --override-filename pkgs/rerun-bin.nix --version="{{ version }}" rerun-bin

[positional-arguments]
rex action="prefetch":
    def main [action: string] {
        if $action not-in [prefetch update] { error make { msg: "Expected rex prefetch or rex update" } }
        let pins = open .tack/pins.lock.json
        let tmp = mktemp --directory
        try {
            let netrc = mktemp --tmpdir-path $tmp netrc.XXXXXX
            ^nix run $"github:($pins.nixpkgs.owner)/($pins.nixpkgs.repo)/($pins.nixpkgs.rev)#age" -- --decrypt --identity ~/.ssh/id_ed25519 secrets/rex.netrc.age out> $netrc
            if $action == "update" {
                let conf = $tmp | path join 'nix.conf'
                $"netrc-file = ($netrc)\n" | save $conf
                TACK_NIX_CONF_TOKENS=1 NIX_USER_CONF_FILES=$conf ^tack update rex
            } else {
                ^nix flake prefetch $"($pins.rex.url)?narHash=($pins.rex.narHash)" --option netrc-file $netrc
            }
        } finally {
            rm --recursive $tmp
        }
    }
