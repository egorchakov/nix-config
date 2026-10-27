def main [] {
    if (which nix | is-not-empty) and ("flake.nix" | path exists) and not (".envrc" | path exists --no-symlink) {
        "use flake" | save .envrc
    }
}
