{ lib, pkgs, ... }: {
  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings.font-size = lib.mkForce 18;
  };

  stylix.fonts.sizes.terminal = 14;
}
