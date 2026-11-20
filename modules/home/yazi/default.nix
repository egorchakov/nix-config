{
  deployHosts,
  hostname,
  lib,
  pkgs,
  profile,
  ...
}:
let
  enableOnnxPreviews =
    hostname == "mbp"
    || builtins.elem (deployHosts.${hostname}.group or null) [
      "kits"
      "ml"
    ];
  preferZerotier =
    deployHosts ? ${hostname}.address.zerotier && !(deployHosts ? ${hostname}.address.warp);
in
{
  programs.yazi = lib.mkMerge [
    {
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
    }
    (lib.mkIf enableOnnxPreviews {
      plugins.piper = pkgs.yaziPlugins.piper;
      extraPackages = [
        (pkgs.python314.withPackages (
          ps:
          [
            ps.polygraphy
            ps.colored
          ]
          ++ ps.polygraphy.optional-dependencies.onnx
        ))
      ];
      settings.plugin.prepend_previewers = lib.mkBefore [
        {
          url = "*.onnx";
          run = "piper -- polygraphy inspect model \"$1\" --show attrs | sed -n '/===/,$p'";
        }
      ];
    })
  ];
}
