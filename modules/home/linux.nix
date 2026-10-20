{ pkgs, profile, ... }: {
  home = {
    inherit (profile) username;
    homeDirectory = "/home/${profile.username}";
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
