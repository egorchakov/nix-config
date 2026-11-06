{
  lib,
  pkgs,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  upstreamLanguages = lib.listToAttrs (
    map (language: lib.nameValuePair language.name language)
      (fromTOML (builtins.readFile "${self.inputs.helix}/languages.toml")).language
  );
  languageOverrides = {
    cpp = {
      auto-format = true;
      language-servers = [ "clangd" ];
    };
    ron = {
      auto-format = true;
      formatter = {
        command = "fmtron";
        args = [
          "--stdin-filepath"
          "%{buffer_name}"
        ];
      };
      language-servers = [ "ron-lsp" ];
    };
    rust = {
      language-servers = [ "rust-analyzer" ];
    };
    markdown = {
      language-servers = [
        "rumdl"
        "mpls"
      ];
    };
    nix = {
      auto-format = true;
      formatter = {
        command = "nixfmt";
        args = [
          "--verify"
          "--strict"
        ];
      };
      language-servers = [
        "nixd"
        "statix"
      ];
    };
    python = {
      auto-format = true;
      language-servers = [
        "ruff"
        "ty"
      ];
    };
    toml = {
      auto-format = true;
      language-servers = [ "tombi" ];
    };
    yaml-config = {
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
        command = "yamlfmt";
        args = [ "-" ];
      };
    };
    yaml = {
      auto-format = true;
      language-servers = [
        "yaml-language-server"
        "ansible-language-server"
      ];
      formatter = {
        command = "yamlfmt";
        args = [ "-" ];
      };
    };
    just = {
      auto-format = true;
      language-servers = [ "just-lsp" ];
      formatter = {
        command = "just";
        args = [
          "--dump"
          "--justfile"
          "-"
        ];
      };
    };
    nu = {
      auto-format = true;
    };
    jq = {
      auto-format = true;
      language-servers = [ "jq-lsp" ];
      formatter = {
        command = "jqfmt";
        args = [
          "-ob"
          "-ar"
        ];
      };
    };
  };
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = self.inputs.helix.packages.${system}.default;
    themes.stylix-brighter-comments = {
      inherits = "stylix";
      comment = {
        fg = "#707070";
        modifiers = [ "italic" ];
      };
    };
    settings = {
      theme = lib.mkForce "stylix-brighter-comments";
      editor = {
        auto-save = true;
        true-color = true;
        idle-timeout = 150;
        auto-completion = true;
        path-completion = true;
        completion-timeout = 5;
        completion-replace = true;

        lsp = {
          auto-document-highlight = true;
          display-progress-messages = true;
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
      language = lib.mapAttrsToList (
        name: language:
        language
        // {
          inherit name;
          language-servers = lib.remove "git-blame" (language.language-servers or [ ]) ++ [ "git-blame" ];
        }
      ) (lib.recursiveUpdate upstreamLanguages languageOverrides);

      language-server = {
        git-blame.command = lib.getExe self.packages.${system}.git-blame-lsp;

        rust-analyzer = {
          config = {
            cargo = {
              features = "all";
              targetDir = true;
            };
            check = {
              command = "clippy";
              workspace = true;
              extraArgs = [
                "--"
                "--no-deps"
              ];
            };
            completion.fullFunctionSignatures.enable = true;
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

        clangd.args = [ "--clang-tidy" ];

        mpls.command = "mpls";

        statix = {
          command = "efm-langserver";
          config = {
            languages = {
              nix = [
                {
                  lintCommand = "statix check --stdin --format=errfmt";
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
      clang-tools
      clippy
      efm-langserver
      jq-lsp
      jqfmt
      just
      just-lsp
      kdlfmt
      mpls
      nixd
      nixfmt
      nufmt
      ruff
      rumdl
      rust-analyzer
      rustfmt
      statix
      tombi
      ty
      vscode-json-languageserver
      yaml-language-server
      yamlfmt
    ];
  };

  xdg.configFile = {
    "helix/runtime/queries/yaml-config".source = ./helix/runtime/queries/yaml-config;
    "helix/runtime/queries/just".source = pkgs.applyPatches {
      name = "helix-just-queries";
      src = "${self.inputs.helix}/runtime/queries/just";
      patches = [ ./patches/helix-just-injections.patch ];
    };
  };
}
