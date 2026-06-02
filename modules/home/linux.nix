{ pkgs, user, ... }: {
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    sessionVariables.NIXOS_OZONE_WL = "1";

    packages = with pkgs; [ systemctl-tui ];
  };
}
