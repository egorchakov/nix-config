{ nix-index-database, ... }: {
  imports = [
    nix-index-database.homeModules.default
    ./stylix.nix
    ./core.nix
    ./codex.nix
    ./git.nix
    ./shell.nix
    ./yazi.nix
    ./helix.nix
  ];
}
