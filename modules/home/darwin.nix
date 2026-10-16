{ pkgs, profile, ... }: {
  home = {
    inherit (profile) username;
    homeDirectory = "/Users/${profile.username}";
    packages = with pkgs; [
      whatsapp-for-mac
      google-chrome
      chatgpt
      slack
      cloudflare-warp
      signal-desktop
      telegram-desktop
      discord
      ffmpeg-headless
      # tfw no map_view
      (callPackage ../../pkgs/rerun-bin.nix { })
    ];
  };
}
