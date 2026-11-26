{ pkgs, self, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  git-surgeon = self.inputs.llm-agents.packages.${system}.git-surgeon;
in
{
  imports = [ self.inputs.agent-skills.homeManagerModules.default ];

  home.packages = [ git-surgeon ];

  programs = {
    agent-skills = {
      enable = true;
      sources = {
        copper.path = self.inputs.copper-rs-skills;
        git-surgeon = {
          path = git-surgeon.src;
          subdir = "skills";
        };
        pohuy = {
          path = self.inputs.pohuy;
          subdir = "skills";
        };
        rust = {
          path = self.inputs.rust-skills;
          subdir = "skills";
        };
      };
      skills.enableAll = true;
      targets = {
        agents = {
          enable = true;
          structure = "link";
          dest = ".agents/skills";
        };
        claude.enable = true;
      };
    };

    mcp.enable = true;

    codex = {
      enable = true;
      enableMcpIntegration = true;
      package = self.inputs.llm-agents.packages.${system}.codex;
      plugins = [ "${pkgs.worktrunk.src}/plugins/worktrunk" ];
      settings = {
        model = "gpt-6.2-sol";
        model_reasoning_effort = "xhigh";
        plan_mode_reasoning_effort = "xhigh";
        service_tier = "fast";
        personality = "pragmatic";
        approval_policy = "never";
        sandbox_mode = "danger-full-access";
        web_search = "live";
        suppress_unstable_features_warning = true;
        tui = {
          theme = "dracula";
          collapse_turn_details = true;
          status_line = [
            "model-with-reasoning"
            "context-remaining"
            "current-dir"
            "git-branch"
            "five-hour-limit"
            "weekly-limit"
            "context-window-size"
            "used-tokens"
          ];
        };
        features = {
          code_mode.enabled = true;
          prevent_idle_sleep = true;
          context_management.experimental_mode = true;
        };
      };
      context = ''
        # code
        ## do
          - strive for the absolute cleanest and tighest design
          - use native library APIs instead of custom helpers
          - use third-party libraries where applicable
          - keep README updates concise and minimal
          - use nushell syntax when giving command examples

        ## do not
          - over-abstract
          - over-comment
          - introduce superfluous structures or single/few-use helpers
          - add tests unless instructed otherwise

        # pull requests
        - follow the conventional commits specifications
        - add mermaid diagrams to PR descriptions where applicable
      '';
    };

    claude-code = {
      enable = true;
      package = self.inputs.llm-agents.packages.${system}.claude-code;
      enableMcpIntegration = true;
    };
  };
}
