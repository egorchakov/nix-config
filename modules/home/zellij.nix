_: {
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "nu";
      simplified_ui = true;
      show_startup_tips = false;
      keybinds = {
        unbind = [
          "Ctrl h"
          "Ctrl n"
          "Ctrl o"
        ];

        "shared_except \"locked\" \"resize\"" = {
          bind = {
            _args = [ "Ctrl z" ];
            _children = [ { SwitchToMode._args = [ "resize" ]; } ];
          };
        };

        "shared_except \"locked\" \"move\"" = {
          bind = {
            _args = [ "Ctrl e" ];
            _children = [ { SwitchToMode._args = [ "move" ]; } ];
          };
        };

        "shared_except \"locked\" \"session\"" = {
          bind = {
            _args = [ "Ctrl s" ];
            _children = [ { SwitchToMode._args = [ "session" ]; } ];
          };
        };
      };
    };
  };
}
