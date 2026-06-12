{ nix-homebrew, profile, ... }: {
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew.user = profile.username;
  nix-homebrew.enable = true;
  nix-homebrew.enableRosetta = true;
  nix-homebrew.autoMigrate = true;

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
