{
  addressedHosts,
  config,
  lib,
  pkgs,
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

  xdg.configFile = {
    "all-smi/config.toml" = {
      force = true;
      text = ''
        [view]
        ssh_hostfile = "${config.xdg.configHome}/all-smi/servers"
        ssh_strict_host_key = "accept-new"
      '';
    };

    "all-smi/servers".text = lib.concatMapStrings (server: "${profile.username}@${server}\n") [
      "aboutblank"
      "berghain"
      "kitkat"
      "renate"
      "sisyphos"
      "tresor"
    ];
  };

  home.activation.allSmiConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.coreutils}/bin/install -Dm600 \
      ${lib.escapeShellArg config.xdg.configFile."all-smi/config.toml".source} \
      ${lib.escapeShellArg "${config.xdg.configHome}/all-smi/config.toml"}
  '';
}
