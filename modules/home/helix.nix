{
  lib,
  pkgs,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  git-blame-lsp = pkgs.stdenv.mkDerivation {
    pname = "git-blame-lsp";
    version = "unstable-${self.inputs.git-blame-lsp.shortRev}";
    src = self.inputs.git-blame-lsp;
    nativeBuildInputs = [
      pkgs.zig_0_16.hook
      pkgs.makeBinaryWrapper
    ];
    postFixup = ''
      wrapProgram $out/bin/git-blame-lsp \
        --prefix PATH : ${lib.makeBinPath [ pkgs.gitMinimal ]}
    '';
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
      language = [
        {
          name = "cpp";
          auto-format = true;
          language-servers = [
            "clangd"
            "git-blame"
          ];
        }
        {
          name = "ron";
          auto-format = true;
          language-servers = [
            "ron-lsp"
            "git-blame"
          ];
        }
        {
          name = "rust";
          language-servers = [
            "rust-analyzer"
            "git-blame"
          ];
        }
        {
          name = "markdown";
          language-servers = [
            "rumdl"
            "mpls"
            "git-blame"
          ];
        }
        {
          name = "nix";
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
            "git-blame"
          ];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [
            "ruff"
            "ty"
            "pyrefly"
            "git-blame"
          ];
        }
        {
          name = "toml";
          auto-format = true;
          language-servers = [
            "tombi"
            "git-blame"
          ];
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
          language-servers = [
            "yaml-language-server"
            "git-blame"
          ];
          formatter = {
            command = "yamlfmt";
            args = [ "-" ];
          };
        }
        {
          name = "yaml";
          auto-format = true;
          language-servers = [
            "yaml-language-server"
            "ansible-language-server"
            "git-blame"
          ];
          formatter = {
            command = "yamlfmt";
            args = [ "-" ];
          };
        }
        {
          name = "just";
          auto-format = true;
          language-servers = [
            "just-lsp"
            "git-blame"
          ];
          formatter = {
            command = "just";
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
        }
        {
          name = "jq";
          auto-format = true;
          language-servers = [ "jq-lsp" ];
          formatter = {
            command = "jqfmt";
            args = [
              "-ob"
              "-ar"
            ];
          };
        }
      ];

      language-server = {
        git-blame.command = "${git-blame-lsp}/bin/git-blame-lsp";

        rust-analyzer = {
          config = {
            cargo.targetDir = true;
            check = {
              command = "clippy";
              workspace = false;
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

        nixd = {
          config.nixd = {
            nixpkgs.expr = ''
              let flake = builtins.getFlake (builtins.toString ./.);
              in flake.inputs.nixpkgs.legacyPackages.${system}
            '';

            options = {
              darwin.expr = ''
                let flake = builtins.getFlake (builtins.toString ./.);
                in flake.darwinConfigurations.mbp.options
              '';

              "home-manager".expr = ''
                let flake = builtins.getFlake (builtins.toString ./.);
                in flake.homeConfigurations."evgenii@mbp".options
              '';

              nixos.expr = ''
                let flake = builtins.getFlake (builtins.toString ./.);
                in flake.nixosConfigurations.t480s.options
              '';
            };
          };
        };

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
      pyrefly
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
    "helix/runtime/queries/just".source = ./helix/runtime/queries/just;
  };
}
