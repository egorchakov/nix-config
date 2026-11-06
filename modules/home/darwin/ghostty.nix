{ pkgs, ... }: {
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
      font-size = pkgs.lib.mkForce 16;
      macos-option-as-alt = "left";
    };
  };
}
