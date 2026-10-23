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
    };
    settings = {
      show_banner = false;
    };
    plugins = with pkgs.nushellPlugins; [
      polars
      query
    ];
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
