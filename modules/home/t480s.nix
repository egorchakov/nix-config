{ pkgs, ... }: {
  imports = [
    ./shared.nix
    ./linux.nix
    ./gui.nix
  ];

  home.packages = with pkgs; [
    bluetui
    pavucontrol
    signal-desktop
    google-chrome
    slack
    telegram-desktop
    impala
    brightnessctl
  ];
}
