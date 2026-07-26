{ config, pkgs, ... }: {
  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings = {
      command = "direct:${pkgs.lib.getExe pkgs.nushell}";
      env = "PATH=/opt/homebrew/bin:/opt/homebrew/sbin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      font-size = pkgs.lib.mkForce 16;
    };
  };
}
