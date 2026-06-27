{ pkgs, self, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  yamlConfigQueries = ./helix/runtime/queries/yaml-config;
  justQueries = ./helix/runtime/queries/just;
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = self.inputs.helix.packages.${system}.default;
    settings = {
      editor = {
        auto-save = true;
        true-color = true;
        idle-timeout = 0;
        auto-completion = true;
        path-completion = true;
        completion-timeout = 5;
        completion-trigger-len = 1;
        completion-replace = true;

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "version-control"
          ];
        };

        indent-guides = {
          render = true;
          skip-levels = 2;
        };

        soft-wrap = {
          enable = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };
      };
      keys = {
        insert = {
          esc = [
            "collapse_selection"
            "normal_mode"
          ];
        };

        normal = {
          ";" = "command_mode";
          d = [
            "yank_joined_to_clipboard"
            "yank"
            "delete_selection"
          ];
          y = [
            "yank_joined_to_clipboard"
            "yank"
          ];
          C-h = "jump_view_left";
          C-j = "jump_view_down";
          C-k = "jump_view_up";
          C-l = "jump_view_right";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
          space = {
            i = ":toggle lsp.display-inlay-hints";
          };
        };

        select = {
          j = [
            "extend_line_down"
            "extend_to_line_bounds"
          ];
          k = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.nixfmt}/bin/nixfmt";
            args = [
              "--verify"
              "--strict"
            ];
          };
          language-servers = [
            "nixd"
            "statix"
          ];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [
            "ruff"
            "ty"
          ];
        }
        {
          name = "toml";
          auto-format = true;
        }
        {
          name = "yaml-config";
          auto-format = true;
          scope = "source.yaml";
          grammar = "yaml";
          language-id = "yaml";
          file-types = [ { glob = "config/**/*.yaml"; } ];
          comment-token = "#";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          language-servers = [ "yaml-language-server" ];
          formatter = {
            command = "${pkgs.yamlfmt}/bin/yamlfmt";
            args = [ "-" ];
          };
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = {
            command = "${pkgs.yamlfmt}/bin/yamlfmt";
            args = [ "-" ];
          };
        }
        {
          name = "just";
          auto-format = true;
          formatter = {
            command = "${pkgs.just}/bin/just";
            args = [
              "--dump"
              "--justfile"
              "-"
            ];
          };
        }
        {
          name = "nu";
          auto-format = true;
          language-servers = [ "nu-lsp" ];
          formatter = {
            command = "${pkgs.nufmt}/bin/nufmt";
            args = [ "--stdin" ];
          };
        }
        {
          name = "jq";
          auto-format = true;
          formatter = {
            command = "${pkgs.jqfmt}/bin/jqfmt";
            args = [
              "-ob"
              "-ar"
            ];
          };
        }
      ];

      language-server = {
        rust-analyzer = {
          config = {
            cargo.allFeatures = true;
            check.command = "clippy";
          };
        };

        ty = {
          command = "ty";
          args = [ "server" ];
          config = {
            experimental = {
              rename = true;
              autoImport = true;
            };
          };
        };

        ruff = {
          command = "ruff";
          args = [ "server" ];
          config.settings.format.preview = true;
        };

        clangd = {
          command = "${pkgs.clang-tools}/bin/clangd";
          args = [ "--clang-tidy" ];
        };

        nixd = {
          command = "${pkgs.nixd}/bin/nixd";
          args = [ "--semantic-tokens=true" ];
        };

        statix = {
          command = "${pkgs.efm-langserver}/bin/efm-langserver";
          config = {
            languages = {
              nix = [
                {
                  lintCommand = "${pkgs.statix}/bin/statix check --stdin --format=errfmt";
                  lintStdIn = true;
                  lintIgnoreExitCode = true;
                  lintFormats = [ "<stdin>>%l:%c:%t:%n:%m" ];
                  rootMarkers = [
                    "flake.nix"
                    "shell.nix"
                    "default.nix"
                  ];
                }
              ];
            };
          };
        };
      };
    };
    extraPackages = with pkgs; [
      tombi
      yaml-language-server
      vscode-json-languageserver
      just-lsp
      ruff
      ty
      rust-analyzer
      rustfmt
      clippy
      jq-lsp
      kdlfmt
    ];
  };

  xdg.configFile = {
    "helix/runtime/queries/yaml-config/highlights.scm" = {
      enable = true;
      source = yamlConfigQueries + "/highlights.scm";
    };

    "helix/runtime/queries/yaml-config/injections.scm" = {
      enable = true;
      source = yamlConfigQueries + "/injections.scm";
    };

    "helix/runtime/queries/yaml-config/textobjects.scm" = {
      enable = true;
      source = yamlConfigQueries + "/textobjects.scm";
    };

    "helix/runtime/queries/yaml-config/indents.scm" = {
      enable = true;
      source = yamlConfigQueries + "/indents.scm";
    };

    "helix/runtime/queries/just/injections.scm" = {
      enable = true;
      source = justQueries + "/injections.scm";
    };
  };
}
