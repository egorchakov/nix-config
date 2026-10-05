set script-interpreter := ["nu"]
set shell := ["nu", "-c"]
set default-script
set lazy

_default:
    just --list

deploy *ARGS:
    deploy {{ ARGS }} -- --log-format internal-json o+e>| nom --json

flow-deps-hash:
    let result = ^nix build --impure --no-link --expr 'let f = builtins.getFlake (toString ./.); flow = builtins.head (builtins.filter (p: (p.pname or "") == "flow-control") f.homeConfigurations."evgenii@mbp".config.home.packages); in flow.zigDeps.overrideAttrs { outputHash = f.inputs.nixpkgs.lib.fakeHash; }' | complete
    let hashes = $result.stderr | lines | parse --regex '^\s*got:\s*(?<hash>\S+)' | get hash
    if ($hashes | is-empty) { error make { msg: $"No dependency hash reported by Nix:\n($result.stderr)" } }
    print ($hashes | first)
