set script-interpreter := ["nu"]
set shell := ["nu", "-c"]
set default-script
set lazy

_default:
    just --list

deploy $target="all": (_tern-archives target)
    let target = $env.target
    let selector = match $target {
        "all" => ["."]
        "ml" | "kits" => ["." "--groups" $target]
        _ => [$".#($target)"]
    }
    ^deploy --no-progress --no-demarcate-output ...$selector -- --log-format internal-json o+e>| ^nom --json

deploy-ml:
    just deploy ml

deploy-kits:
    just deploy kits

tern-prefetch $system="aarch64-darwin":
    let archive = ^nix eval --json $".#packages.($env.system).tern.src" --apply 'src: { inherit (src) name outputHash; }' | from json
    ^nix store prefetch-file --json --name $archive.name --expected-hash $archive.outputHash $"file://($env.PWD)/assets/($archive.name)"
    | from json
    | get storePath

_tern-archives $target:
    let target = $env.target
    let nodes = ^nix eval --json .#deploy.nodes --apply 'nodes: builtins.mapAttrs (_: node: { inherit (node) hostname groups sshUser sshOpts; system = node.profiles.home.path.system; }) nodes' | from json | transpose name node
    let selected = match $target {
        "all" => $nodes
        "ml" | "kits" => ($nodes | where {|host| $target in $host.node.groups })
        _ => ($nodes | where name == $target)
    }
    if ($selected | is-empty) { error make $"Unknown deployment target: ($target)" }
    let archives = $selected.node.system | uniq | each {|system|
        {system: $system, path: (^just tern-prefetch $system | str trim)}
    }
    for host in $selected {
        let archive = $archives | where system == $host.node.system | first
        with-env {NIX_SSHOPTS: ($host.node.sshOpts | str join ' ')} {
            ^nix copy --to $"ssh-ng://($host.node.sshUser)@($host.node.hostname)" $archive.path
        }
    }

flow-deps-hash:
    let result = ^nix build --impure --no-link --expr 'let f = builtins.getFlake (toString ./.); flow = builtins.head (builtins.filter (p: (p.pname or "") == "flow-control") f.homeConfigurations."evgenii@mbp".config.home.packages); in flow.zigDeps.overrideAttrs { outputHash = f.inputs.nixpkgs.lib.fakeHash; }' | complete
    let hashes = $result.stderr | lines | parse --regex '^\s*got:\s*(?<hash>\S+)' | get hash
    if ($hashes | is-empty) { error make { msg: $"No dependency hash reported by Nix:\n($result.stderr)" } }
    print ($hashes | first)
