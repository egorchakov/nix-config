{ pkgs, ... }: {
  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings.font-size = pkgs.lib.mkForce 16;
  };
}
