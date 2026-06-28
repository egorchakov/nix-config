{ self, profile, ... }: {
  imports = [ self.inputs.nix-homebrew.darwinModules.nix-homebrew ];

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
      "display-pilot"
    ];
    onActivation = {
      cleanup = "uninstall";
      upgrade = true;
      autoUpdate = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
