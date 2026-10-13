{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nushell = {
    enable = true;
    shellAliases = {
      cx = "codex --profile interactive";
      zl = "zellij";
      nf = "nix flake";
      hd = "herdr";
      hdr = "herdr --remote";
      bssh = "bssh -o ClearAllForwardings=yes";
    };
    environmentVariables = config.home.sessionVariables;
    settings = {
      show_banner = false;
    };
    plugins = with pkgs.nushellPlugins; [
      polars
      query
    ];
    extraEnv = ''
      use std/util "path add"

      if "${config.home.profileDirectory}/bin" not-in $env.PATH {
        path add ${
          lib.hm.nushell.toNushell { } (
            [
              "${config.home.profileDirectory}/bin"
              "/run/current-system/sw/bin"
              "/nix/var/nix/profiles/default/bin"
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
              "/opt/homebrew/bin"
              "/opt/homebrew/sbin"
            ]
          )
        }
      }
    '';
    extraConfig =
      let
        nushellCustomCompletions = [
          "aerospace"
          "nix"
          "gh"
          "git"
          "just"
          "rg"
          # "ssh"
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
            codex --profile interactive $"/goal explain why this command failed and suggest a fix: ($cmd)"
        }

        def ns [...packages: string] {
            ^nix shell ...($packages | each {|p| $"nixpkgs#($p)"})
        }
      '';
  };
}
