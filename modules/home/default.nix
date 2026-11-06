{ ... }: {
  imports = [
    ./agents.nix
    ./vcs.nix
    ./helix.nix
    ./nushell.nix
    ./cli.nix
    ./stylix.nix
    ./yazi
  ];

  news.display = "silent";
  manual.manpages.enable = false;

  home.stateVersion = "26.11";

  programs.home-manager.enable = true;
}
