def main [] {
    if not ("flake.nix" | path exists) or (".envrc" | path exists --no-symlink) or (which nix | is-empty) {
        return
    }

    let result = ^nix eval --impure --json --no-write-lock-file .#devShells --apply 'shells: shells ? ${builtins.currentSystem}.default' | complete
    if $result.exit_code == 0 and ($result.stdout | from json) {
        "use flake" | save .envrc
    }
}
