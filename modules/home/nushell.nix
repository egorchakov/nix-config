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
      nf = "nix flake";
      hd = "herdr";
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
    extraConfig = ''
      def why [] {
          let cmd = history | last | get command
          codex --profile interactive $"explain why this failed: ($cmd)"
      }

      def ns [...packages: string] {
          ^nix shell ...($packages | each {|p| $"nixpkgs#($p)"})
      }
    '';
  };
}
