{ pkgs, profile, ... }: {
  home = {
    inherit (profile) username;
    homeDirectory = "/home/${profile.username}";
    sessionVariables.NIXOS_OZONE_WL = "1";

    packages = with pkgs; [ systemctl-tui ];
  };

  programs.nushell.extraEnv = ''
    if $nu.is-interactive and ($env.SSH_CONNECTION? != null) and ($env.SSH_AUTH_SOCK? != null) {
      let forwarded_agent = $env.HOME | path join ".ssh" "forwarded-agent.sock"

      if ($env.ZELLIJ? == null) and ($env.SSH_AUTH_SOCK != $forwarded_agent) {
        ${pkgs.coreutils}/bin/ln -sfn $env.SSH_AUTH_SOCK $forwarded_agent
      }

      $env.SSH_AUTH_SOCK = $forwarded_agent
    }
  '';
}
