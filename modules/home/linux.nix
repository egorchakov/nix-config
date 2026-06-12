{ pkgs, profile, ... }: {
  home = {
    inherit (profile) username;
    homeDirectory = "/home/${profile.username}";
    sessionVariables.NIXOS_OZONE_WL = "1";

    packages = with pkgs; [ systemctl-tui ];
  };
}
