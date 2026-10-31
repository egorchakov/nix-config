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

flow-deps-hash:
    let result = ^nix build --impure --no-link --expr 'let f = builtins.getFlake (toString ./.); flow = builtins.head (builtins.filter (p: (p.pname or "") == "flow-control") f.homeConfigurations."evgenii@mbp".config.home.packages); in flow.zigDeps.overrideAttrs { outputHash = f.inputs.nixpkgs.lib.fakeHash; }' | complete
    let hashes = $result.stderr | lines | parse --regex '^\s*got:\s*(?<hash>\S+)' | get hash
    if ($hashes | is-empty) { error make { msg: $"No dependency hash reported by Nix:\n($result.stderr)" } }
    print ($hashes | first)
