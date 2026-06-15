{ nix-homebrew, profile, ... }: {
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    user = profile.username;
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    greedyCasks = false;
    casks = [
      "tunnelblick"
      "uhk-agent"
      "display-pimot"
    ];
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = false;
    };
  };
}
