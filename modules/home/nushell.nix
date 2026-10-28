{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionPath = [
    "${config.home.profileDirectory}/bin"
    "/run/wrappers/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  programs.nushell = {
    enable = true;
    shellAliases = {
      cx = "codex --profile interactive";
      nf = "nix flake";
      hd = "herdr";
      bssh = "bssh -o ClearAllForwardings=yes";
      wj = "wt switch";
    };
    settings = {
      show_banner = false;
    };
    plugins = with pkgs.nushellPlugins; [
      polars
      query
    ];
    extraConfig = ''
      def y [] {
          let cmd = history | last | get command
          codex --profile interactive $"explain why this failed: ($cmd)"
      }

      def ns [...packages: string] {
          ^nix shell ...($packages | each {|p| $"nixpkgs#($p)"})
      }

      # Update all flake inputs except the names given before the first Nix option.
      def --wrapped nix-flake-update-except [...args] {
          let excluded = $args | take while {|arg| not ($arg | str starts-with "-")}
          let options = $args | skip ($excluded | length)
          if ($excluded | is-empty) {
              ^nix flake update ...$options
          } else {
              let lock = open flake.lock | from json
              let inputs = $lock.nodes | get $lock.root | get inputs | reject ...$excluded | columns
              if ($inputs | is-not-empty) {
                  ^nix flake update ...$inputs ...$options
              }
          }
      }
    '';
  };
}
