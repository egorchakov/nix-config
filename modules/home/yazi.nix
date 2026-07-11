{ pkgs, ... }: {
  programs.yazi = {
    enable = true;
    shellWrapperName = "f";
    plugins = {
      inherit (pkgs.yaziPlugins)
        full-border
        starship
        git
        ouch
        rsync
        ;
    };
    extraPackages = with pkgs; [ ouch ];
    settings = {
      plugin = {
        prepend_previewers =
          map
            (type: {
              run = "ouch";
              mime = "application/${type}";
            })
            [
              "*zip"
              "x-tar"
              "x-bzip2"
              "x-7z-compressed"
              "x-rar"
              "x-xz"
              "xz"
            ];
      };
    };
    keymap = {
      mgr = {
        prepend_keymap = [
          {
            on = "R";
            run = "plugin rsync -- --remember";
            desc = "rsync";
          }
        ];
      };
    };
    initLua = ''
      require("full-border"):setup {
        type = ui.Border.PLAIN,
      }
      require("starship"):setup()
      require("git"):setup()
    '';
  };
}
