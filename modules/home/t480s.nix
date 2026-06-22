{ pkgs, ... }: {
  imports = [
    ./shared.nix
    ./linux.nix
    ./gui.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    signal-desktop
    telegram-desktop
    slack
    systemctl-tui
    nextdns
  ];
}
