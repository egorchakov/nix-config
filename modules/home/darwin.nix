{ pkgs, profile, ... }: {
  imports = [ ./darwin/rex.nix ];

  home = {
    inherit (profile) username;
    homeDirectory = "/Users/${profile.username}";
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
      (callPackage ../../pkgs/rerun-bin.nix { })
    ];
  };
}
