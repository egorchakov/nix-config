{
  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable?shallow=1";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix/master?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix?shallow=1";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew?shallow=1";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix?shallow=1";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      profile = {
        username = "evgenii";
        git = {
          name = "Evgenii Gorchakov";
          email = "evgorchakov@gmail.com";
        };
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      specialArgs = { inherit self profile; };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ inputs.nur.overlays.default ];
        };

      pkgsFor = lib.genAttrs systems mkPkgs;

      deployHosts = {
        aboutblank = "x86_64-linux";
        berghain = "x86_64-linux";
        delta-dev1 = "aarch64-linux";
        kitkat = "x86_64-linux";
        renate = "x86_64-linux";
        sisyphos = "x86_64-linux";
        tresor = "x86_64-linux";
      };

      deploySystems = lib.unique (lib.attrValues deployHosts);

      deployPkgsFor = lib.genAttrs deploySystems (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.deploy-rs.overlays.default
            (_: prev: {
              deploy-rs = {
                inherit (pkgs) deploy-rs;
                lib = prev.deploy-rs.lib;
              };
            })
          ];
        }
      );

      mkHome =
        { system, modules }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.${system};
          extraSpecialArgs = specialArgs;
          inherit modules;
        };

    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
      ];

      flake = {
        nixosConfigurations.t480s = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/t480s ];
        };

        darwinConfigurations.mbp = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit specialArgs;
          modules = [ ./hosts/mbp ];
        };

        homeConfigurations = {
          "${profile.username}@mbp" = mkHome {
            system = "aarch64-darwin";
            modules = [ ./hosts/mbp/home.nix ];
          };

          "${profile.username}@t480s" = mkHome {
            system = "x86_64-linux";
            modules = [ ./hosts/t480s/home.nix ];
          };

          x86_64-linux = mkHome {
            system = "x86_64-linux";
            modules = [
              ./modules/home/shared.nix
              ./modules/home/linux.nix
            ];
          };

          aarch64-linux = mkHome {
            system = "aarch64-linux";
            modules = [
              ./modules/home/shared.nix
              ./modules/home/linux.nix
            ];
          };
        };

        deploy.nodes = lib.mapAttrs (hostname: system: {
          inherit hostname;
          remoteBuild = true;
          autoRollback = true;
          magicRollback = true;
          activationTimeout = 600;
          confirmTimeout = 60;
          sshOpts = [
            "-o"
            "ControlMaster=no"
            "-o"
            "ControlPath=none"
          ];

          profiles.home = {
            user = profile.username;
            path =
              deployPkgsFor.${system}.deploy-rs.lib.activate.home-manager
                self.homeConfigurations.${system};
          };
        }) deployHosts;
      };

      perSystem =
        { config, system, ... }:
        let
          pkgs = pkgsFor.${system};
        in
        {
          _module.args.pkgs = pkgs;

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
            };
            settings.excludes = [
              ".git/*"
              "flake.lock"
            ];
            settings.formatter = {
              deadnix.priority = 1;
              statix.priority = 2;
              nixfmt.priority = 3;
            };
          };

          pre-commit = {
            settings = {
              package = pkgs.prek;
              hooks = {
                treefmt.enable = true;
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

          checks = lib.optionalAttrs (system == "x86_64-linux") (
            deployPkgsFor.${system}.deploy-rs.lib.deployChecks self.deploy
          );

          devShells.default =
            with pkgs;
            mkShell {
              inputsFrom = [ config.pre-commit.devShell ];
              packages = [
                nushell
                just
                skim
                pkgs.deploy-rs
                direnv
                gitMinimal
                nix-direnv
                nix-output-monitor
                openssh
                ragenix
              ];
            };
        };
    };
}
