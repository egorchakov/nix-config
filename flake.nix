{
  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://cache.manic.systems"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
    ];
  };

  outputs =
    { self }:
    let
      inputs = import ./.tack // {
        inherit self;
      };
      inherit (inputs) nixpkgs;
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
          inputs
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

          packages = lib.optionalAttrs (system == "aarch64-darwin") {
            rerun-bin = pkgs.callPackage ./pkgs/rerun-bin.nix { };
          };

          checks = lib.optionalAttrs (system == "x86_64-linux") (
            deployPkgsFor.${system}.deploy-rs.lib.deployChecks self.deploy
          );
        };
    };
}
