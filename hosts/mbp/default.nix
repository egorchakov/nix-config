{
  networkHosts,
  config,
  lib,
  self,
  pkgs,
  profile,
  ...
}:
let
  yaakNetStagingNetworkId = "12ac4a1e71b101f1";
  nasHosts = lib.filterAttrs (_: host: host.group == "nas") networkHosts;

  hostsFile = pkgs.writeText "hosts" ''
    127.0.0.1 localhost
    255.255.255.255 broadcasthost
    ::1 localhost

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: { address, ... }: "${address.warp or address.zerotier}\t${name}"
      ) networkHosts
    )}
  '';
in
{
  imports = [ ../../modules/darwin/homebrew.nix ];

  nix.enable = false;

  services.tailscale.enable = true;

  environment.systemPath = lib.mkOrder 1100 [
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
  ];

  launchd.user.envVariables.PATH =
    lib.replaceStrings [ "$HOME" ] [ config.users.users.${profile.username}.home ]
      config.environment.systemPath;

  system = {
    primaryUser = profile.username;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;

    defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 0;
    };
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    nushell
  ];

  environment.etc = {
    "auto_master" = {
      knownSha256Hashes = [ "b2aac03248e8f229c703561f5bb059f9be491e5db9f447692398d775a9fb12a5" ];
      text = ''
        +auto_master
        /home auto_home -nobrowse,hidefromfinder
        /Network/Servers -fstab
        /- -static
        /- auto_nas
      '';
    };
    "auto_nas".text = lib.concatLines (
      lib.mapAttrsToList (
        name:
        { address, ... }:
        "/Volumes/${name} -fstype=nfs,ro,soft,intr,nosuid ${address.warp or address.zerotier}:/volume1/data"
      ) nasHosts
    );
  };

  users = {
    knownGroups = [ "data" ];
    groups.data = {
      gid = 2000;
      members = [ profile.username ];
    };
    users.${profile.username} = {
      home = "/Users/${profile.username}";
      shell = pkgs.nushell;
    };
  };

  networking = {
    computerName = "mbp";
    hostName = "mbp";
    localHostName = "mbp";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  launchd.daemons.nas-mounts = {
    script = ''
      set -e
      /bin/mkdir -p ${lib.escapeShellArgs (map (name: "/Volumes/${name}") (builtins.attrNames nasHosts))}
      /usr/sbin/automount -vc
    '';
    serviceConfig.RunAtLoad = true;
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    ${pkgs.coreutils}/bin/install \
      --owner=root \
      --group=wheel \
      --mode=0644 \
      ${hostsFile} \
      /etc/hosts

    ${pkgs.coreutils}/bin/install -d -m 0700 "/Library/Application Support/ZeroTier/One/networks.d"
    if [ ! -e "/Library/Application Support/ZeroTier/One/networks.d/${yaakNetStagingNetworkId}.conf" ]; then
      ${pkgs.coreutils}/bin/touch "/Library/Application Support/ZeroTier/One/networks.d/${yaakNetStagingNetworkId}.conf"
      /bin/launchctl kickstart -k system/com.zerotier.one
    fi

    ${config.launchd.daemons.nas-mounts.command}
  '';
}
