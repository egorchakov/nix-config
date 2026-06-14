{ pkgs, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    overlays.enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/evenok-dark.yaml";
    fonts = {
      monospace = {
        package = pkgs.iosevka-bin;
        name = "Iosevka";
      };
      sizes.terminal = 14;
    };
  };
}
