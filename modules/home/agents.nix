{ pkgs, self, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs = {

    mcp = {
      enable = true;
      servers = {
        rerun = {
          enabled = false; # TODO: enable once https://github.com/NixOS/nixpkgs/pull/539089
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
        model = "gpt-5.5";
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
          apply_patch_freeform = true;
          fast_mode = true;
          multi_agent = true;
          remote_models = true;
          runtime_metrics = true;
          shell_snapshot = true;
          unified_exec = true;
          goals = true;
          hooks = true;
          memories = true;
          prevent_idle_sleep = true;
          undo = true;
        };
      };
    };
  };
}
