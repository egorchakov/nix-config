{
  addressedHosts,
  lib,
  profile,
  ...
}:
{
  imports = [
    ../../modules/home/shared.nix
    ../../modules/home/gui.nix
    ../../modules/home/darwin.nix
    ../../modules/home/darwin/aerospace.nix
    ../../modules/home/darwin/terminal.nix
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraOptionOverrides.IgnoreUnknown = "UseKeychain";
    includes = [ "~/.ssh/config.local" ];

    settings = {
      "${lib.concatStringsSep " " (builtins.attrNames addressedHosts)}" = {
        IdentityFile = "~/.ssh/id_rsa";
        ForwardAgent = true;
        AddKeysToAgent = true;
        UseKeychain = true;
        AddressFamily = "inet";
        Compression = true;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%h:%p.socket";
        ControlPersist = "30m";
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
        SetEnv.TERM = "xterm-256color";
        RemoteForward = "9878 localhost:9878";
        StrictHostKeyChecking = "accept-new";
      };

      "router.lan" = {
        User = profile.username;
        Port = 2200;
      };
    };
  };
}
