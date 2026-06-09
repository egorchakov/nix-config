{ pkgs, ... }: {
  stylix = {
    enable = true;
    autoEnable = false;
    overlays.enable = true;
    targets = {
      bat.enable = true;
      "font-packages".enable = true;
      fontconfig.enable = true;
      helix.enable = true;
      nushell.enable = true;
      starship.enable = true;
      yazi.enable = true;
      zellij.enable = true;
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/evenok-dark.yaml";
    fonts = {
      monospace = {
        package = pkgs.iosevka-bin;
        name = "Iosevka";
      };
    };
  };
}
