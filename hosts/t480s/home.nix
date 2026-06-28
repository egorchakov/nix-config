{ pkgs, ... }: {
  imports = [
    ../../modules/home/shared.nix
    ../../modules/home/linux.nix
    ../../modules/home/gui.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    signal-desktop
    telegram-desktop
    slack
    playerctl
    brightnessctl
  ];
}
