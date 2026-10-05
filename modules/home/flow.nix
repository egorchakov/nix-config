{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  flow = (pkgs.flow-control.override { zig_0_15 = pkgs.zig_0_16; }).overrideAttrs (old: {
    version = "unstable-${self.inputs.flow.shortRev}";
    src = self.inputs.flow;
    zigDeps = old.zigDeps.overrideAttrs {
      outputHash = "sha256-nXp69dBrNH0VexHX8APJApBPb60FBFif7QnYBZ6awmk=";
    };
    zigBuildFlags = [
      "--system"
      "zig-deps"
    ]
    ++ lib.drop 2 old.zigBuildFlags;
    preBuild = ''
      mkdir -p zig-deps
      for archive in "$zigDeps"/*.tar.gz; do
        # The optional fuzzing dependency still targets an older Zig API.
        case "$archive" in */libfuzzer_kit-*) continue ;; esac
        tar -xf "$archive" -C zig-deps
      done
    '';
    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];
    postFixup = ''
      wrapProgram $out/bin/flow \
        --suffix PATH : ${lib.makeBinPath config.programs.helix.extraPackages}
    '';
  });

  toConf = lib.generators.toKeyValue { mkKeyValue = key: value: "${key} ${builtins.toJSON value}"; };

  fileTypes = {
    cpp = {
      description = "C++";
      color = "#9c033a";
      icon = "";
      extensions = [
        "cc"
        "cpp"
        "cxx"
        "hpp"
        "hxx"
        "h"
        "ipp"
        "ixx"
      ];
      comment = "//";
      parser = "cpp";
      language_server = [
        "clangd"
        "--clang-tidy"
      ];
      formatter = [
        "clang-format"
        "--assume-filename={{file}}"
      ];
    };
    rust = {
      description = "Rust";
      color = "#000000";
      icon = "󱘗";
      extensions = [ "rs" ];
      comment = "//";
      parser = "rust";
      language_server = [ "rust-analyzer" ];
      formatter = [ "rustfmt" ];
    };
    markdown = {
      description = "Markdown";
      color = "#000000";
      icon = "󰍔";
      extensions = [
        "md"
        "smd"
      ];
      comment = "<!--";
      parser = "markdown";
      language_server = [
        "rumdl"
        "server"
      ];
      formatter = [
        "rumdl"
        "fmt"
        "--stdin"
        "--stderr"
      ];
    };
    nix = {
      description = "Nix";
      color = "#5277c3";
      icon = "󱄅";
      extensions = [ "nix" ];
      comment = "#";
      parser = "nix";
      language_server = [ "nixd" ];
      formatter = [
        "nixfmt"
        "--verify"
        "--strict"
        "-"
      ];
    };
    python = {
      description = "Python";
      color = "#ffd845";
      icon = "󰌠";
      extensions = [
        "py"
        "pyi"
      ];
      first_line_matches_prefix = "#!";
      first_line_matches_content = "python";
      comment = "#";
      parser = "python";
      language_server = [
        "ty"
        "server"
      ];
      formatter = [
        "ruff"
        "format"
        "--preview"
        "--stdin-filename"
        "{{file}}"
        "-"
      ];
    };
    toml = {
      description = "TOML";
      color = "#ffffff";
      icon = "󱀫";
      extensions = [
        "toml"
        "ini"
      ];
      comment = "#";
      parser = "toml";
      language_server = [
        "tombi"
        "lsp"
      ];
      formatter = [
        "tombi"
        "format"
        "-"
      ];
    };
    yaml = {
      description = "YAML";
      color = "#000000";
      icon = "";
      extensions = [
        "yaml"
        "yml"
      ];
      comment = "#";
      parser = "yaml";
      language_server = [
        "yaml-language-server"
        "--stdio"
      ];
      formatter = [
        "yamlfmt"
        "-"
      ];
    };
    nu = {
      description = "Nushell";
      color = "#3aa675";
      icon = ">";
      extensions = [
        "nu"
        "nushell"
      ];
      comment = "#";
      parser = "nu";
      language_server = [
        "nu"
        "--lsp"
      ];
      formatter = [
        "nufmt"
        "--stdin"
      ];
    };
    ron = {
      description = "RON";
      extensions = [ "ron" ];
      comment = "//";
      language_server = [ "ron-lsp" ];
      formatter = [
        "fmtron"
        "--stdin-filepath"
        "{{file}}"
      ];
    };
    just = {
      description = "Just";
      extensions = [
        "just"
        "justfile"
        "Justfile"
        ".justfile"
      ];
      comment = "#";
      language_server = [ "just-lsp" ];
      formatter = [
        "just"
        "--dump"
        "--justfile"
        "-"
      ];
    };
    jq = {
      description = "jq";
      extensions = [ "jq" ];
      comment = "#";
      language_server = [ "jq-lsp" ];
      formatter = [
        "jqfmt"
        "-ob"
        "-ar"
      ];
    };
  };

in
{
  home.packages = [ flow ];

  xdg.configFile."flow".source = pkgs.linkFarm "flow-config" (
    {
      config = pkgs.writeText "flow-config" (toConf {
        input_mode = "helix";
        theme = "helix";
        light_theme = "helix";
        enable_auto_save = true;
        auto_save_mode = "on_focus_change";
        input_idle_time_ms = 150;
        completion_trigger = "automatic";
        completion_insert_mode = "replace";
        idle_actions = [ "highlight_references" ];
        gutter_line_numbers_mode = "absolute";
        whitespace_mode = "indent";
        bottom_bar = "mode file spacer diagnostics branch lsp";
        show_bottom_bar_grip = false;
        enable_format_on_save = true;
      });
      "keys/helix.json" = ./flow/helix.json;
      "themes/helix.json" = pkgs.writeText "flow-helix-theme.json" (
        builtins.toJSON (import ./flow/theme.nix { inherit config lib self; })
      );
      file_type = pkgs.runCommand "flow-file-types" { } ''
        mkdir -p $out
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: settings: ''
            cp ${pkgs.writeText "${name}.conf" (toConf (settings // { inherit name; }))} $out/${name}.conf
          '') fileTypes
        )}
      '';
    }
    // lib.mapAttrs' (
      name: server:
      lib.nameValuePair "lsp/${name}.json" (pkgs.writeText "${name}.json" (builtins.toJSON server.config))
    ) (lib.getAttrs [ "rust-analyzer" "ty" ] config.programs.helix.languages.language-server)
  );
}
