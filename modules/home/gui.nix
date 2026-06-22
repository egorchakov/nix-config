{ pkgs, ... }: {
  home.packages = with pkgs; [ winbox ];

  programs = {
    ghostty = {
      enable = true;
      settings = {
        window-inherit-working-directory = true;
        window-decoration = false;
        focus-follows-mouse = true;
        shell-integration-features = "sudo,ssh-env,ssh-terminfo";
      };
    };
    sioyek = {
      enable = true;
      config = {
        case_sensitive_search = "0";
        default_dark_mode = "1";
        dark_mode_background_color = "0.0 0.0 0.0";
        font_size = "20";
        prerender_next_page_presentation = "1";
        should_launch_new_window = "1";
        super_fast_search = "1";
      };
    };
  };

  stylix.targets = {
    gtk.enable = true;
    sioyek.enable = true;
    ghostty.enable = true;
  };
}
