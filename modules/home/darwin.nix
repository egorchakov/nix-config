{
  config,
  hostname,
  lib,
  pkgs,
  profile,
  self,
  ...
}:
let
  rerun = self.packages.${pkgs.stdenv.hostPlatform.system}.rerun-bin;
in
{
  imports = [ ./darwin/rex.nix ];

  home = {
    inherit (profile) username;
    homeDirectory = "/Users/${profile.username}";
    sessionPath = lib.splitString ":" (
      lib.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ]
        self.darwinConfigurations.${hostname}.config.environment.systemPath
    );
    packages = with pkgs; [
      whatsapp-for-mac
      google-chrome
      chatgpt
      slack
      signal-desktop
      telegram-desktop
      discord
      ffmpeg-headless
      bitwarden-desktop
      bitwarden-cli
      # tfw no map_view
      rerun
    ];
  };

  programs.mcp.servers.rerun = {
    enabled = true;
    command = lib.getExe rerun;
    args = [ "viewer-mcp" ];
    env.RUST_LOG = "re_viewer_mcp=info,warn";
  };
}
