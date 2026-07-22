{ pkgs, ... }: {
  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings = {
      command = "direct:${pkgs.lib.getExe pkgs.nushell}";
      font-size = pkgs.lib.mkForce 16;
    };
  };
}
