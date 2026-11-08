{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  toml = pkgs.formats.toml { };
  upstreamLanguages = lib.listToAttrs (
    map (language: lib.nameValuePair language.name language)
      (fromTOML (builtins.readFile "${self.inputs.mitos}/languages.toml")).language
  );
in
{
  # TODO: Replace configuration generation and wrapping with native Home Manager Mitos support.
  home.packages = [
    (pkgs.symlinkJoin {
      name = "mitos";
      paths = [ self.inputs.mitos.packages.${system}.default ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ms \
          --suffix PATH : ${
            lib.makeBinPath (
              with pkgs;
              [
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
                nixfmt-rs
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
                nushell
                ron-lsp
              ]
            )
          }
      '';
    })
  ];

  home.sessionVariables = {
    EDITOR = "ms";
    VISUAL = "ms";
  };

  xdg.configFile = {
    "mitos/config.toml".source = toml.generate "mitos-config.toml" {
      theme = "stylix-brighter-comments";
      terminal.true-color = true;
      editor = {
        idle-timeout = 150;
        files.auto-save.focus-lost = true;
        clipboard.default-yank-register = "+";
        inline-blame.show = "cursor-line";
        completion = {
          trigger-delay = 5;
          replace = true;
        };
        lsp = {
          progress.enable = true;
          inlay-hints.enable = true;
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "branch"
          ];
        };
        indent-guides = {
          render = true;
          skip-levels = 2;
        };
        soft-wrap.enable = true;
        file-picker.hidden = false;
        cursor.shape = {
          insert = "bar";
          select = "underline";
        };
        border-style = "plain";
      };
      keys = {
        insert.esc = [
          "collapse_selection"
          "normal_mode"
        ];
        normal = {
          ";" = "command_mode";
          C-h = "jump_view_left";
          C-j = "jump_view_down";
          C-k = "jump_view_up";
          C-l = "jump_view_right";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
          space.i = ":toggle lsp.inlay-hints.enable";
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

    "mitos/languages.toml".source = toml.generate "mitos-languages.toml" {
      language = lib.mapAttrsToList (name: language: language // { inherit name; }) {
        jq.formatter = {
          command = "jqfmt";
          args = [
            "-ob"
            "-ar"
          ];
        };
        markdown.language-servers = upstreamLanguages.markdown.language-servers ++ [ "mpls" ];
        nix = {
          formatter = {
            command = "nixfmt";
            args = [ "--verify" ];
          };
          language-servers = upstreamLanguages.nix.language-servers ++ [ "statix" ];
        };
        nu.auto-format = true;
        ron.formatter = {
          command = "fmtron";
          args = [
            "--stdin-filepath"
            "%{buffer_name}"
          ];
        };
      };
      language-server = {
        rust-analyzer.config = {
          cargo = {
            features = "all";
            targetDir = true;
          };
          check = {
            command = "clippy";
            extraArgs = [
              "--"
              "--no-deps"
            ];
          };
          completion.fullFunctionSignatures.enable = true;
        };
        clangd.args = [ "--clang-tidy" ];
        mpls.command = "mpls";
        statix = {
          command = "efm-langserver";
          config.languages.nix = [
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
        ruff.config.settings.format.preview = true;
      };
    };

    "mitos/themes/stylix.toml".source = config.lib.stylix.colors {
      templateRepo = self.inputs.stylix.inputs.base16-helix;
      target = "base16";
    };
    "mitos/themes/stylix-brighter-comments.toml".source =
      toml.generate "mitos-theme-stylix-brighter-comments.toml"
        {
          inherits = "stylix";
          comment = {
            fg = "#707070";
            modifiers = [ "italic" ];
          };
        };

    "mitos/runtime/queries/yaml/injections.scm".text =
      builtins.readFile "${self.inputs.mitos}/runtime/queries/yaml/injections.scm"
      + "\n"
      + builtins.readFile ./mitos/runtime/queries/yaml/injections.scm;
    "mitos/runtime/queries/just".source = pkgs.applyPatches {
      name = "mitos-just-queries";
      src = "${self.inputs.mitos}/runtime/queries/just";
      patches = [ ./patches/just-injections.patch ];
    };
  };
}
