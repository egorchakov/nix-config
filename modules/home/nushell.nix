{ config, pkgs, ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      cx = "codex --profile interactive";
      zl = "zellij";
      nf = "nix flake";
      gi = "gst-inspect-1.0";
      gl = "gst-launch-1.0";
    };
    environmentVariables = config.home.sessionVariables;
    settings = {
      show_banner = false;
    };
    plugins = with pkgs.nushellPlugins; [
      polars
      query
    ];
    extraConfig =
      let
        nushellCustomCompletions = [
          "aerospace"
          "nix"
          "gh"
          "git"
          "just"
          "rg"
          "ssh"
          "uv"
          "television"
          "zellij"
          "zoxide"
        ];
      in
      ''
        const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${pkgs.nu_scripts}/share/nu_scripts']

        ${pkgs.lib.concatMapStringsSep "\n" (
          name: "use custom-completions/${name}/${name}-completions.nu *"
        ) nushellCustomCompletions}

        def why [] {
            let cmd = history | last | get command
            codex --profile interactive $"/goal explain why this command failed and suggest a fix: ($cmd)"
        }
      '';
  };
}
