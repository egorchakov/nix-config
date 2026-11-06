{ pkgs, ... }: {
  home.packages = with pkgs; [
    winbox
    qpdf
    poppler-utils
  ];

  programs = {
    ghostty = {
      enable = true;
      settings = {
        window-inherit-working-directory = true;
        window-decoration = false;
        focus-follows-mouse = true;
        shell-integration-features = "sudo,no-ssh-env,no-ssh-terminfo";
      };
    };
  };

  stylix = {
    fonts = {
      monospace = {
        package = pkgs.iosevka-bin;
        name = "Iosevka Fixed";
      };
      sizes.terminal = 14;
    };
    targets = {
      font-packages.enable = true;
      fontconfig.enable = true;
      gtk.enable = true;
      ghostty.enable = true;
    };
  };
}
