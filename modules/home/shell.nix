{
  config,
  pkgs,
  nix-index-database,
  ...
}:
{
  imports = [ nix-index-database.homeModules.default ];
  home.packages = with pkgs; [
    tig
    just
    dust
    rsync
    nur.repos.doomhammer.gitpane
  ];

  programs = {
    bat.enable = true;
    ripgrep.enable = true;
    skim.enable = true;
    zoxide.enable = true;
    uv.enable = true;
    bottom.enable = true;
    htop.enable = true;
    gh.enable = true;
    nix-your-shell = {
      enable = true;
      nix-output-monitor.enable = true;
    };
    carapace.enable = true;
    nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/dev/nix-config";
    };
    nix-index-database.comma.enable = true;
    television.enable = true;
    nix-search-tv.enable = true;
    fd.enable = true;

    direnv = {
      enable = true;
      silent = true;
      config.global.warn_timeout = "120s";
      nix-direnv.enable = true;
    };

    atuin = {
      enable = true;
      settings = {
        auto_sync = false;
        update_check = false;
        search_mode = "skim";
        search_mode_shell_up_key_binding = "skim";
        inline_height = 10;
        keymap_mode = "vim-insert";
      };
    };

    starship = {
      enable = true;
      settings.format = "$username$hostname$directory$git_branch$git_state$nix_shell$direnv$python\n$character";
    };

    nushell = {
      enable = true;
      shellAliases = {
        cx = "codex";
        zl = "zellij";
        nf = "nix flake";
        gi = "gst-inspect-1.0";
        gl = "gst-launch-1.0";
      };
      environmentVariables = config.home.sessionVariables;
      settings = {
        show_banner = false;
      };
      plugins = with pkgs.nushellPlugins; [
        polars
        query
      ];
      extraConfig =
        let
          nushellCustomCompletions = [
            "aerospace"
            "nix"
            "gh"
            "git"
            "just"
            "rg"
            "ssh"
            "uv"
            "television"
            "zellij"
            "zoxide"
          ];
        in
        ''
          const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${pkgs.nu_scripts}/share/nu_scripts']

          ${pkgs.lib.concatMapStringsSep "\n" (
            name: "use custom-completions/${name}/${name}-completions.nu *"
          ) nushellCustomCompletions}

          def why [] {
              let cmd = history | last | get command
              codex $"/goal explain why this command failed and suggest a fix: ($cmd)"
          }
        '';
    };

    zellij = {
      enable = true;
      settings = {
        default_shell = "nu";
        simplified_ui = true;
        show_startup_tips = false;
        keybinds = {
          unbind = [
            "Ctrl h"
            "Ctrl n"
            "Ctrl o"
          ];

          "shared_except \"locked\" \"resize\"" = {
            bind = {
              _args = [ "Ctrl z" ];
              _children = [ { SwitchToMode._args = [ "resize" ]; } ];
            };
          };

          "shared_except \"locked\" \"move\"" = {
            bind = {
              _args = [ "Ctrl e" ];
              _children = [ { SwitchToMode._args = [ "move" ]; } ];
            };
          };

          "shared_except \"locked\" \"session\"" = {
            bind = {
              _args = [ "Ctrl s" ];
              _children = [ { SwitchToMode._args = [ "session" ]; } ];
            };
          };
        };
      };
    };
  };
}
