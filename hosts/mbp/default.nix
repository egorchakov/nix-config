{
  config,
  lib,
  self,
  pkgs,
  profile,
  ...
}:
{
  imports = [ ../../modules/darwin/homebrew.nix ];

  nix.enable = false;

  launchd.user.envVariables.PATH = lib.concatStringsSep ":" [
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
    (lib.replaceStrings [ "$HOME" ] [ "/Users/${profile.username}" ] config.environment.systemPath)
  ];

  system = {
    primaryUser = profile.username;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    nushell
  ];

  users.users."${profile.username}" = {
    home = "/Users/${profile.username}";
    shell = pkgs.nushell;
  };

  networking = {
    computerName = "mbp";
    hostName = "mbp";
    localHostName = "mbp";
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
