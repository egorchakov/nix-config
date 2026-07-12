{ ... }: {
  imports = [
    ./agents.nix
    ./core.nix
    ./vcs.nix
    ./helix.nix
    ./nushell.nix
    ./shell.nix
    ./stylix.nix
    ./yazi.nix
    ./zellij.nix
  ];
}
