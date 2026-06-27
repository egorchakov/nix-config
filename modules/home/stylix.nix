{ pkgs, self, ... }: {
  imports = [
    self.inputs.stylix.homeModules.stylix
    {
      disabledModules = map (name: "${self.inputs.stylix}/modules/${name}/hm.nix") [
        "blender"
        "kde"
        "gnome"
        "gnome-text-editor"
        "eog"
      ];
    }
  ];

  stylix = {
    enable = true;
    overlays.enable = true;
    autoEnable = false;
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
      sizes.terminal = 14;
    };
  };
}
