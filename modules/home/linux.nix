{
  config,
  pkgs,
  profile,
  ...
}:
{
  home = {
    inherit (profile) username;
    homeDirectory = "/home/${profile.username}";
    sessionPath = [
      "${config.home.profileDirectory}/bin"
      "/run/wrappers/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";

    packages = with pkgs; [ systemctl-tui ];

    file.".zshenv" = {
      force = true;
      text = ''
        if [ ! -e /etc/NIXOS ] && [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
      '';
    };
  };
}
