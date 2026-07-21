{ pkgs, self, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.herdr = {
    enable = true;
    package = self.inputs.llm-agents.packages.${system}.herdr;
    settings = {
      onboarding = false;
      terminal.default_shell = "nu";
      theme.name = "kanagawa";
      update = {
        version_check = false;
        manifest_check = false;
      };
      ui = {
        sidebar_start_collapsed = true;
        sidebar_collapsed_mode = "hidden";
        sidebar = {
          spaces = {
            row_gap = 1;
          };
          agents = {
            row_gap = 1;
            rows = [
              [
                "state_icon"
                "workspace"
                "agent"
                "state_text"
              ]
              [
                "tab"
                "pane"
              ]
            ];
          };
        };
        prompt_new_tab_name = false;
        pane_gaps = false;
        sound.enabled = false;
      };
      experimental = {
        kitty_graphics = true;
      };
    };
  };
}
