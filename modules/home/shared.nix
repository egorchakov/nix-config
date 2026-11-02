{ ... }: {
  imports = [
    ./agents.nix
    ./core.nix
    ./vcs.nix
    ./helix.nix
    # ./flow.nix
    ./nushell.nix
    ./shell.nix
    ./stylix.nix
    ./yazi
  ];
}
