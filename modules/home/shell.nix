{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [ self.inputs.nix-index-database.homeModules.default ];
  home.packages = with pkgs; [
    tig
    just
    dust
    rsync
  ];

  programs = {
    bat.enable = true;
    delta.enable = true;
    ripgrep.enable = true;
    skim.enable = true;
    zoxide.enable = true;
    uv.enable = true;
    bottom.enable = true;
    htop.enable = true;
    gh.enable = true;
    nix-your-shell = {
      enable = true;
      nix-output-monitor.enable = true;
    };
    carapace.enable = true;
    nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/dev/nix-config";
    };
    nix-index-database.comma.enable = true;
    television.enable = true;
    nix-search-tv.enable = true;
    fd.enable = true;

    direnv = {
      enable = true;
      silent = true;
      config.global.warn_timeout = "120s";
      nix-direnv.enable = true;
    };

    atuin = {
      enable = true;
      settings = {
        auto_sync = false;
        update_check = false;
        search_mode = "skim";
        search_mode_shell_up_key_binding = "skim";
        inline_height = 10;
        keymap_mode = "vim-insert";
      };
    };

    starship = {
      enable = true;
      settings.format = "$username$hostname$directory$git_branch$git_state$nix_shell$direnv$python\n$character";
    };
  };
}
