{ pkgs, stylix, ... }: {
  imports = [ stylix.homeModules.stylix ];
  disabledModules = map (x: "${stylix}/modules/${x}/hm.nix") [
    "blender"
    "kde"
    "qt"
    "hyprpanel"
    "qutebrowser"
    "opencode"
    "gnome"
    "discord"
    "vscode"
    "zed"
    "zen-browser"
    "neovim"
    "obsidian"
    "emacs"
  ];

  stylix = {
    enable = true;
    autoEnable = true;
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
