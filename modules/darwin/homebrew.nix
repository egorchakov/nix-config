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
    brews = [
      "lablup/tap/all-smi"
      "lablup/tap/bssh"
    ];
    casks = [
      "cloudflare-warp"
      "tunnelblick"
      "uhk-agent"
      "display-pilot"
      "zerotier-one"
    ];
    onActivation = {
      cleanup = "uninstall";
      upgrade = true;
      autoUpdate = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
