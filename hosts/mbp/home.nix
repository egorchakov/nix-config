{
  addressedHosts,
  config,
  lib,
  pkgs,
  profile,
  ...
}:
let
  hostGroups = lib.groupBy (name: addressedHosts.${name}.group) (builtins.attrNames addressedHosts);
in
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
        all.nodes = builtins.attrNames addressedHosts;
      };
    };
  };

  home.activation.allSmiConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.coreutils}/bin/install -Dm600 \
      ${lib.escapeShellArg config.xdg.configFile."all-smi/config.toml".source} \
      ${lib.escapeShellArg "${config.xdg.configHome}/all-smi/config.toml"}
  '';
}
