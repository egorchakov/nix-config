{
  pkgs,
  self,
  profile,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = [ self.inputs.llm-agents.packages.${system}.hunk ];

  programs = {
    git = {
      enable = true;
      settings = {
        user = { inherit (profile.git) email name; };
        push.autoSetupRemote = true;
      };

      lfs.enable = true;
    };

    difftastic = {
      enable = true;
      git = {
        enable = true;
        mode = "both";
      };
    };

    gitui = {
      enable = true;
    };
  };

  xdg.configFile = {
    "hunk/config.toml" = {
      force = true;
      source = (pkgs.formats.toml { }).generate "hunk-config.toml" {
        watch = true;
        transparent_background = true;
        keybindings = {
          "hunk.review.nextFile" = "shift+j";
          "hunk.review.previousFile" = "shift+k";
        };
      };
    };

    "tig/config" = {
      enable = true;
      text = ''
        bind main R !git rebase -i %(commit)^
        bind diff R !git rebase -i %(commit)^
      '';
    };
  };
}
