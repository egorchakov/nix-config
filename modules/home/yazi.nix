{ pkgs, ... }:
let
  archiveMimeSuffixes = [
    "*zip"
    "x-tar"
    "x-bzip2"
    "x-7z-compressed"
    "x-rar"
    "x-xz"
    "xz"
  ];

  tabularPreviewExtensions = [
    "csv"
    "tsv"
    "parquet"
    "xlsx"
    "db"
    "duckdb"
  ];

  tabularPreloaderExtensions = [
    "csv"
    "tsv"
    "json"
    "parquet"
    "txt"
    "xlsx"
  ];
in
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "f";
    plugins = {
      inherit (pkgs.yaziPlugins)
        full-border
        chmod
        starship
        git
        duckdb
        ouch
        rsync
        ;
    };
    extraPackages = with pkgs; [
      duckdb
      ouch
    ];
    settings = {
      plugin = {
        prepend_previewers =
          map (type: {
            run = "ouch";
            mime = "application/${type}";
          }) archiveMimeSuffixes
          ++ map (type: {
            run = "duckdb";
            url = "*.${type}";
          }) tabularPreviewExtensions;

        prepend_preloaders = map (type: {
          run = "duckdb";
          url = "*.${type}";
          multi = false;
        }) tabularPreloaderExtensions;
      };
    };
    keymap = {
      mgr = {
        prepend_keymap = [
          {
            on = "R";
            run = "plugin rsync";
            desc = "rsync";
          }
          {
            on = "H";
            run = "plugin duckdb -1";
            desc = "scroll one column to the left";
          }
          {
            on = "L";
            run = "plugin duckdb +1";
            desc = "scroll one column to the right";
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
      require("duckdb"):setup()
    '';
  };
}
