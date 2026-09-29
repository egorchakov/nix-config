{ pkgs, profile, ... }: {
  home = {
    inherit (profile) username;
    homeDirectory = "/home/${profile.username}";
    sessionVariables.NIXOS_OZONE_WL = "1";

    packages = with pkgs; [ systemctl-tui ];

    file.".zshenv".text = ''
      if [ ! -e /etc/NIXOS ] && [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';

    # Herdr's remote attach does not start an interactive shell.
    file.".ssh/rc".text = ''
      if [ -S "$SSH_AUTH_SOCK" ]; then
        ${pkgs.coreutils}/bin/ln -sfn "$SSH_AUTH_SOCK" "$HOME/.ssh/forwarded-agent.sock"
      fi

      # sshd also delegates X11 authentication to this hook.
      if [ -n "$DISPLAY" ] && read -r proto cookie; then
        case "$DISPLAY" in
          localhost:*) display="unix:''${DISPLAY#localhost:}" ;;
          *) display="$DISPLAY" ;;
        esac
        ${pkgs.xauth}/bin/xauth -q add "$display" "$proto" "$cookie"
      fi
    '';
  };

  programs.nushell.extraEnv = ''
    if $nu.is-interactive and (($env.SSH_CONNECTION? != null) or ($env.HERDR_ENV? != null) or ($env.ZELLIJ? != null)) {
      let forwarded_agent = $env.HOME | path join ".ssh" "forwarded-agent.sock"

      if ($forwarded_agent | path exists) {
        $env.SSH_AUTH_SOCK = $forwarded_agent
      }
    }
  '';
}
