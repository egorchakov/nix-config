{
  lib,
  pkgs,
  profile,
  ...
}:
let
  rerun = (pkgs.rerun.override { buildWebViewerFeatures = [ "map_view" ]; }).overrideAttrs (
    old:
    let
      rerunFeatures = lib.unique ((old.cargoBuildFeatures or old.buildFeatures or [ ]) ++ [ "map_view" ]);
    in
    {
      buildFeatures = rerunFeatures;
      cargoBuildFeatures = rerunFeatures;
      cargoCheckFeatures = rerunFeatures;
    }
  );
in
{
  home = {
    inherit (profile) username;
    homeDirectory = "/Users/${profile.username}";
    packages = with pkgs; [
      whatsapp-for-mac
      google-chrome
      chatgpt
      slack
      # bitwarden-desktop
      # telegram-desktop
      rerun
      cloudflare-warp
      signal-desktop
    ];
  };
}
