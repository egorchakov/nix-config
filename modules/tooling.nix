{ inputs, ... }: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          deadnix.enable = true;
          statix.enable = true;
          nixfmt = {
            enable = true;
            strict = true;
          };
          just.enable = true;
          keep-sorted.enable = true;
          rumdl-format.enable = true;
          stylua.enable = true;
        };
        settings.excludes = [
          ".git/*"
          ".tack/default.nix"
        ];
        settings.formatter = {
          deadnix.priority = 1;
          statix.priority = 2;
          nixfmt.priority = 3;
          schemat = {
            command = lib.getExe pkgs.schemat;
            includes = [ "*.scm" ];
          };
        };
      };

      pre-commit = {
        settings = {
          package = pkgs.prek;
          hooks = {
            treefmt = {
              enable = true;
              pass_filenames = false;
            };
            trim-trailing-whitespace.enable = true;
            end-of-file-fixer.enable = true;
            check-merge-conflicts.enable = true;
            check-symlinks.enable = true;
            check-case-conflicts.enable = true;
            check-added-large-files.enable = true;
            check-json.enable = true;
          };
        };
      };

      devShells.default =
        with pkgs;
        mkShell {
          name = "nix-config";
          inputsFrom = [ config.pre-commit.devShell ];
          packages = [
            nushell
            just
            deploy-rs
            direnv
            gh
            gitMinimal
            nix-direnv
            (nix-update.override {
              nix = inputs.determinate.inputs.nix.packages.${stdenv.hostPlatform.system}.default;
            })
            openssh
            ragenix
            rom
            inputs.tack.packages.${stdenv.hostPlatform.system}.default
          ];
        };
    };
}
