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
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "git-hooks/flake-compat";
        utils.inputs.systems.follows = "llm-agents/systems";
      };
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "determinate/nix/git-hooks-nix/flake-compat";
      };
    };

    helix.url = "github:helix-editor/helix/master";

    rex = {
      url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

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
      url = "github:nix-community/stylix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "llm-agents/systems";
      };
    };

    git-blame-lsp = {
      url = "github:credimusin/git-blame-lsp";
      flake = false;
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    copper-rs-skills = {
      url = "github:copper-project/copper-rs-skills";
      flake = false;
    };

    rust-skills = {
      url = "github:actionbook/rust-skills";
      flake = false;
    };

    pohuy = {
      url = "github:smixs/pohuy";
      flake = false;
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

      hosts = import ./hosts/inventory.nix;

      networkHosts = lib.filterAttrs (_: host: host ? address) hosts;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      specialArgs = {
        inherit
          self
          profile
          networkHosts
          deployHosts
          ;
      };

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
        { hostname, modules }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.${hosts.${hostname}.system};
          extraSpecialArgs = specialArgs // {
            inherit hostname;
          };
          inherit modules;
        };

    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;

      imports = [ ./modules/tooling.nix ];

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
            hostname = "mbp";
            modules = [ ./hosts/mbp/home.nix ];
          };

          "${profile.username}@t480s" = mkHome {
            hostname = "t480s";
            modules = [ ./hosts/t480s/home.nix ];
          };
        }
        // lib.mapAttrs (
          hostname: _:
          mkHome {
            inherit hostname;
            modules = [ ./modules/home/server.nix ];
          }
        ) deployHosts;

        deploy.nodes = lib.mapAttrs (hostname: { system, group, ... }: {
          inherit hostname;
          groups = [ group ];
          sshUser = profile.username;
          remoteBuild = true;
          autoRollback = true;
          magicRollback = true;
          activationTimeout = 600;
          confirmTimeout = 60;
          sshOpts = [
            "-o"
            "BatchMode=yes"
            "-o"
            "ConnectTimeout=10"
            "-o"
            "ClearAllForwardings=yes"
            "-o"
            "ControlMaster=no"
            "-o"
            "ControlPath=none"
          ];

          profiles.home = {
            user = profile.username;
            path =
              deployPkgsFor.${system}.deploy-rs.lib.activate.home-manager
                self.homeConfigurations.${hostname};
          };
        }) deployHosts;
      };

      perSystem =
        { system, ... }:
        let
          pkgs = pkgsFor.${system};
        in
        {
          _module.args.pkgs = pkgs;

          packages = {
            git-blame-lsp = pkgs.callPackage ./pkgs/git-blame-lsp.nix { src = inputs.git-blame-lsp; };
          }
          // lib.optionalAttrs (system == "aarch64-darwin") {
            rerun-bin = pkgs.callPackage ./pkgs/rerun-bin.nix { };
          };

          checks = lib.optionalAttrs (system == "x86_64-linux") (
            deployPkgsFor.${system}.deploy-rs.lib.deployChecks self.deploy
          );
        };
    };
}
