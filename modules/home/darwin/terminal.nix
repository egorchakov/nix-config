{ pkgs, ... }: {
  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings = {
      command = "${pkgs.lib.getExe pkgs.bashInteractive} -l -c 'exec ${pkgs.lib.getExe pkgs.nushell}'";
      font-size = pkgs.lib.mkForce 16;
    };
  };
}
