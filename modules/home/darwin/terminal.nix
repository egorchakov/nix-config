{ config, pkgs, ... }: {
  programs.nushell.extraConfig = ''
    $env.config.hooks.pre_prompt = (
      $env.config.hooks.pre_prompt?
      | default []
      | prepend {||
          if $env.GHOSTTY_RESOURCES_DIR? != null and (ps | where pid == $nu.pid | get ppid.0) == 1 {
            exit
          }
        }
    )
  '';

  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings = {
      command = "direct:${pkgs.lib.getExe pkgs.nushell}";
      env = "PATH=/opt/homebrew/bin:/opt/homebrew/sbin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      font-size = pkgs.lib.mkForce 16;
      macos-option-as-alt = "left";
    };
  };
}
