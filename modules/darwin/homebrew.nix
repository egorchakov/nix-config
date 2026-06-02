{ nix-homebrew, user, ... }: {
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    inherit user;
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    greedyCasks = false;
    casks = [
      "tunnelblick"
      "cloudflare-warp"
      "netron"
      "signal"
      "uhk-agent"
      "spotify"
      "display-pilot"
    ];
    brews = [ "TeddyHuang-00/app/sshping" ];
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = false;
    };
  };
}
