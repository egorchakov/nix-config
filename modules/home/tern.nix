{
  addressedHosts,
  config,
  lib,
  pkgs,
  profile,
  self,
  ...
}:
let
  tern = self.packages.${pkgs.stdenv.hostPlatform.system}.tern;
  ternConfigDir = "${config.xdg.configHome}/tern";
  knownHosts = pkgs.writeText "tern-known-hosts" (
    lib.concatStrings (
      lib.mapAttrsToList (_: host: "${host.address}:8376 ${host.tern.fingerprint}\n") (
        lib.filterAttrs (_: host: (host.tern.fingerprint or null) != null) addressedHosts
      )
    )
  );
in
{
  home = {
    packages = [ tern ];
    sessionVariables.TERN_CONFIG_DIR = ternConfigDir;
    activation = {
      ternSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run ${pkgs.coreutils}/bin/install -Dm600 \
          ${config.xdg.configFile."tern/settings.json".source} \
          ${lib.escapeShellArg "${ternConfigDir}/settings.json"}
      '';
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      ternKnownHosts = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run ${pkgs.coreutils}/bin/install -Dm600 \
          ${knownHosts} \
          ${lib.escapeShellArg "${ternConfigDir}/known_hosts"}
      '';
    };
  };

  systemd.user.services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    tern-remote = {
      Unit = {
        Description = "Tern remote sessions";
        StartLimitIntervalSec = 60;
        StartLimitBurst = 10;
      };
      Service = {
        Type = "exec";
        ExecStart = pkgs.writeShellScript "tern-remote" ''
          if [ -e /etc/NIXOS ]; then
            set -- --authorized-keys ${lib.escapeShellArg "/etc/ssh/authorized_keys.d/${config.home.username}"}
          fi
          exec ${lib.getExe tern} remote serve --user \
            --state-dir ${lib.escapeShellArg ternConfigDir} "$@"
        '';
        Restart = "on-failure";
        RestartSec = 2;
        RestartPreventExitStatus = 2;
        KillMode = "process";
        TimeoutStopSec = 10;
        Environment = "TERN_CONFIG_DIR=${ternConfigDir}";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  xdg.configFile = {
    "tern/settings.json" = {
      force = true;
      source = (pkgs.formats.json { }).generate "tern-settings.json" {
        theme = "Dark";
        theme_dark = "dark-midnight";
        copy_on_select = true;
        smooth_scroll = false;
        layout = "Rail";
        font_size = 16;
        ui_font_size = 16;
        font_family = "Iosevka";
        ui_font = "Iosevka";
        code_font = "Iosevka";
        agent_command = "codex --profile interactive";
        shell = lib.getExe config.programs.nushell.package;
        native_prompt = false;
        auto_update = false;
        ask_to_move = false;
        tabs = "Vertical";
        tabs_autohide = false;
        keybinds = {
          "ctrl+b>h" = "focus_pane:left";
          "ctrl+b>j" = "focus_pane:down";
          "ctrl+b>k" = "focus_pane:up";
          "ctrl+b>l" = "focus_pane:right";
          "ctrl+b>v" = "split_right";
          "ctrl+b>-" = "split_down";
          "ctrl+b>x" = "close_pane";
          "ctrl+b>tab" = "next_pane";
          "ctrl+b>shift+tab" = "previous_pane";
          "ctrl+b>n" = "next_tab";
          "ctrl+b>p" = "previous_tab";
          "ctrl+b>]" = "next_tab_across_sessions";
          "ctrl+b>[" = "previous_tab_across_sessions";
          "ctrl+b>1" = "goto_tab:1";
          "ctrl+b>2" = "goto_tab:2";
          "ctrl+b>3" = "goto_tab:3";
          "ctrl+b>4" = "goto_tab:4";
          "ctrl+b>5" = "goto_tab:5";
          "ctrl+b>6" = "goto_tab:6";
          "ctrl+b>7" = "goto_tab:7";
          "ctrl+b>8" = "goto_tab:8";
          "ctrl+b>9" = "goto_tab:9";
          "ctrl+b>g" = "switch_session";
        };
        agents = {
          keep_tui = [
            "copilot"
            "claude"
          ];
          show_claude_thinking = false;
          own_tools = [ "codex" ];
        };
      };
    };
    "tern/plugins" = {
      source = ./tern/plugins;
      recursive = true;
    };
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    "tern/hosts" = {
      force = true;
      text = lib.concatStrings (
        lib.mapAttrsToList (name: host: "${profile.username}@${host.address}\t${name}\n") addressedHosts
      );
    };
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    "systemd/user/tern-remote.service".force = true;
    "systemd/user/default.target.wants/tern-remote.service".force = true;
  };
}
