{
  deployHosts,
  hostname,
  lib,
  pkgs,
  profile,
  ...
}:
let
  preferZerotier =
    deployHosts ? ${hostname}.address.zerotier && !(deployHosts ? ${hostname}.address.warp);
in
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "f";
    vfs.sftp = lib.mapAttrs (_: host: {
      host =
        if preferZerotier then
          host.address.zerotier or host.address.warp
        else
          host.address.warp or host.address.zerotier;
      user = profile.username;
      port = 22;
    }) deployHosts;
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
    theme =
      let
        padding = {
          open = "▐";
          close = "▌";
        };
      in
      {
        indicator.padding = padding;
        tabs = {
          sep_inner = padding;
          sep_outer = padding;
        };

      };

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
            on = "d";
            run = "remove --permanently";
          }
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
      dofile("${./init.lua}")(${lib.generators.toLua { } (builtins.attrNames deployHosts)})
    '';
  };
}
