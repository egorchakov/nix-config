{ pkgs, profile, ... }: {
  home = {
    inherit (profile) username;
    homeDirectory = "/Users/${profile.username}";
    packages = with pkgs; [
      whatsapp-for-mac
      google-chrome
      chatgpt
      slack
      rerun
      cloudflare-warp
      signal-desktop
      telegram-desktop
    ];
  };
}
