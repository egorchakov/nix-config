{ pkgs, ... }: {
  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings = {
      command = "${pkgs.lib.getExe pkgs.bashInteractive} -l -c nu";
      font-size = pkgs.lib.mkForce 16;
    };
  };
}
