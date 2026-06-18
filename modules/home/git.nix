{ profile, ... }: {
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

    delta.enable = true;
  };

  xdg.configFile."tig/config" = {
    enable = true;
    text = ''
      bind main R !git rebase -i %(commit)^
      bind diff R !git rebase -i %(commit)^
    '';
  };
}
