{ pkgs, self, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [ self.inputs.agent-skills.homeManagerModules.default ];

  programs = {
    agent-skills = {
      enable = true;
      sources = {
        copper.path = self.inputs.copper-rs-skills;
        pohuy = {
          path = self.inputs.pohuy;
          subdir = "skills";
        };
      };
      skills.enableAll = true;
      targets.agents = {
        enable = true;
        structure = "link";
        dest = ".agents/skills";
      };
    };

    mcp = {
      enable = true;
      servers = {
        rerun = {
          enabled = true;
          command = "rerun"; # TODO: binpath?
          args = [ "viewer-mcp" ];
          env.RUST_LOG = "re_viewer_mcp=info,warn";
        };
      };

    };
    codex = {
      enable = true;
      enableMcpIntegration = true;
      package = self.inputs.llm-agents.packages.${system}.codex;
      settings = {
        model = "gpt-6-astra";
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
        ## do
          - strive for the absolute cleanest and tighest design
          - use native library APIs instead of custom helpers
          - use third-party libraries where applicable

        ## do not
          - over-abstract
          - introduce superfluous structs or single/few-use helpers
          - add tests unless instructed otherwise
          - reinvent the wheel
          - add unnecessary comments
      '';
    };
  };
}
