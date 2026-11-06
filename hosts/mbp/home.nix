{
  networkHosts,
  lib,
  pkgs,
  profile,
  ...
}:
let
  hostGroups = lib.groupBy (name: networkHosts.${name}.group) (builtins.attrNames networkHosts);
in
{
  imports = [
    ../../modules/home/default.nix
    ../../modules/home/desktop.nix
    ../../modules/home/darwin.nix
    ../../modules/home/darwin/aerospace.nix
    ../../modules/home/darwin/ghostty.nix
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraOptionOverrides.IgnoreUnknown = "UseKeychain";
    includes = [ "~/.ssh/config.local" ];

    settings = {
      "${lib.concatStringsSep " " (hostGroups.ml ++ hostGroups.kits)}" = {
        IdentityFile = "~/.ssh/id_ed25519";
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
        RemoteForward = "9878 localhost:9878";
        StrictHostKeyChecking = "accept-new";
        LogLevel = "QUIET";
      };

      "${lib.concatStringsSep " " hostGroups.nas}" = {
        User = "yaak";
        PreferredAuthentications = "password";
        PasswordAuthentication = true;
        PubkeyAuthentication = false;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%h:%p.socket";
        ControlPersist = "24h";
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };

      "github.com" = {
        AddKeysToAgent = true;
        IdentityFile = "~/.ssh/id_ed25519";
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
      source = (pkgs.formats.toml { }).generate "all-smi-config.toml" {
        view.hosts = map (server: "http://${server}:9091") (lib.remove "berghain" hostGroups.ml);
      };
    };

    "bssh/config.yaml".source = (pkgs.formats.yaml { }).generate "bssh-config.yaml" {
      defaults.user = profile.username;
      clusters = lib.mapAttrs (_: nodes: { inherit nodes; }) hostGroups // {
        all.nodes = builtins.attrNames networkHosts;
      };
    };
  };
}
