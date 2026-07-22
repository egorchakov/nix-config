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

      hosts = {
        mbp.system = "aarch64-darwin";
        t480s.system = "x86_64-linux";

        aboutblank = {
          address = "192.168.207.247";
          system = "x86_64-linux";
        };
        berghain = {
          address = "192.168.207.244";
          system = "x86_64-linux";
        };
        kitkat = {
          address = "192.168.207.239";
          system = "x86_64-linux";
        };
        renate = {
          address = "192.168.207.246";
          system = "x86_64-linux";
        };
        sisyphos = {
          address = "192.168.207.241";
          system = "x86_64-linux";
        };
        tresor = {
          address = "192.168.207.242";
          system = "x86_64-linux";
        };
        delta-dev1 = {
          address = "192.168.144.35";
          system = "aarch64-linux";
        };
        delta-emc1.address = "172.30.0.40";
      };

      addressedHosts = lib.filterAttrs (_: host: host ? address) hosts;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      specialArgs = { inherit self profile addressedHosts; };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      pkgsFor = lib.genAttrs systems mkPkgs;

      deployHosts = lib.filterAttrs (_: host: host ? address && host ? system) hosts;

      deploySystems = lib.unique (lib.mapAttrsToList (_: host: host.system) deployHosts);

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
          inherit (hosts.t480s) system;
          inherit specialArgs;
          modules = [ ./hosts/t480s ];
        };

        darwinConfigurations.mbp = inputs.darwin.lib.darwinSystem {
          inherit (hosts.mbp) system;
          inherit specialArgs;
          modules = [ ./hosts/mbp ];
        };

        homeConfigurations = {
          "${profile.username}@mbp" = mkHome {
            inherit (hosts.mbp) system;
            modules = [ ./hosts/mbp/home.nix ];
          };

          "${profile.username}@t480s" = mkHome {
            inherit (hosts.t480s) system;
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

        deploy.nodes = lib.mapAttrs (hostname: { system, ... }: {
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
