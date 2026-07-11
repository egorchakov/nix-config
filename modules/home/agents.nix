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
        model = "gpt-5.6-sol";
        model_reasoning_effort = "max";
        plan_mode_reasoning_effort = "max";
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
          code_mode = true;
          hooks = true;
          memories = true;
          prevent_idle_sleep = true;
        };
      };
      context = ''
        ## guiding principles
          - strive for the absolute minimal diff
          - use as much third-party code as possible where applicable
          - use native library APIs instead of custom helpers
          - if introducing a new data structure, opt for the cleanest and tightest design

        ## strictly forbidden
          - over-abstraction
          - superfluous structs or single/few-use helpers
          - adding tests unless instructed otherwise
          - reinventing the wheel

        ## tool preferences
          - "nix develop" for nix-managed projects
          - "nix run" for one-off commands if a tool is missing
          - nushell for shell tasks

        ## language-specific preferences
        ### rust
          - prefer long method chains over single-use intermediate variables
          - prefer methods over free functions
          - consult https://blessed.rs/crates when picking a crate
      '';
    };
  };
}
