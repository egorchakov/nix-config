{
  lib,
  pkgs,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [ ./herdr/plugins.nix ];

  programs.herdr = {
    enable = true;
    package = self.inputs.llm-agents.packages.${system}.herdr;
    plugins = [ (pkgs.callPackage ../../pkgs/herdr-sesh.nix { }) ];
    settings = {
      onboarding = false;
      terminal.default_shell = lib.getExe pkgs.nushell;
      theme.name = "kanagawa";
      update = {
        version_check = false;
        manifest_check = false;
      };
      remote.manage_ssh_config = true;
      ui = {
        sidebar_start_collapsed = true;
        sidebar_collapsed_mode = "hidden";
        prompt_new_tab_name = false;
        pane_gaps = false;
        sound.enabled = false;
      };
      experimental = {
        kitty_graphics = true;
      };
      keys = {
        settings = "prefix+comma";
        next_agent = "prefix+]";
        previous_agent = "prefix+[";
        copy_mode = "prefix+shift+c";
        command = [
          {
            key = "prefix+s";
            type = "plugin_action";
            command = "fullerzz.sesh.open-picker";
            description = "open Sesh picker";
          }
        ];
      };
    };
  };
}
