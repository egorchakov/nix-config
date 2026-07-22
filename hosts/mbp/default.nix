{
  addressedHosts,
  config,
  lib,
  self,
  pkgs,
  profile,
  ...
}:
let
  hostsFile = pkgs.writeText "hosts" ''
    127.0.0.1 localhost
    255.255.255.255 broadcasthost
    ::1 localhost

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: { address, ... }: "${address}\t${name}") addressedHosts
    )}
  '';
in
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

  system.activationScripts.postActivation.text = lib.mkAfter ''
    ${pkgs.coreutils}/bin/install \
      --owner=root \
      --group=wheel \
      --mode=0644 \
      ${hostsFile} \
      /etc/hosts
  '';
}
