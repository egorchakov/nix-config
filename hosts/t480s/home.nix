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
  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox service";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      Restart = "on-failure";
    };
  };
}
