{
  config,
  hostname,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./shared.nix
    ./linux.nix
    self.inputs.rex.homeManagerModules.default
  ];

  services.rex = {
    enable = true;
    environment.SSH_AUTH_SOCK = "${config.home.homeDirectory}/.ssh/rex-agent.sock";
    tailscale = {
      enable = true;
      hostname = "rex-${hostname}";
    };
  };

  home.file.".local/libexec/rex-forward-agent".source = pkgs.lib.getExe (
    pkgs.writeShellApplication {
      name = "rex-forward-agent";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        if [[ -z "''${SSH_AUTH_SOCK:-}" || ! -S "''${SSH_AUTH_SOCK:-}" ]]; then
          echo "SSH agent forwarding is unavailable" >&2
          exit 1
        fi

        socket="$HOME/.ssh/rex-agent.sock"
        install -d -m 0700 "$HOME/.ssh"
        ln -sfn -- "$SSH_AUTH_SOCK" "$socket"
        trap 'if [[ "$(readlink "$socket")" == "$SSH_AUTH_SOCK" ]]; then rm -f -- "$socket"; fi' EXIT
        trap 'exit 0' HUP INT TERM
        sleep infinity &
        wait "$!"
      '';
    }
  );

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  systemd.user.services.rex.Unit.X-SwitchMethod = "restart";
}
