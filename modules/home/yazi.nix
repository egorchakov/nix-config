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
        duckdb
        ;
    };
    extraPackages = with pkgs; [
      ouch
      duckdb
    ];
    settings = {
      plugin = {
        prepend_previewers =
          map
            (url: {
              inherit url;
              run = "duckdb";
            })
            [
              "*.csv"
              "*.parquet"
            ]
          ++
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
        prepend_preloaders =
          map
            (url: {
              inherit url;
              run = "duckdb";
            })
            [
              "*.csv"
              "*.parquet"
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
          {
            on = [
              "g"
              "o"
            ];
            run = "plugin duckdb -open";
            desc = "open with duckdb";
          }
          {
            on = [
              "g"
              "u"
            ];
            run = "plugin duckdb -ui";
            desc = "open with duckdb ui";
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
      require("duckdb"):setup({
        mode = "standard",
        cache_size = 100,
      })
    '';
  };
}
