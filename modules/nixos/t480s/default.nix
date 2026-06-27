{
  config,
  pkgs,
  profile,
  self,
  ...
}:
let
  inherit (profile) username;
in
{
  imports = [
    self.inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
    self.inputs.srvos.nixosModules.desktop
    self.inputs.agenix.nixosModules.default
    ./hardware-configuration.nix
  ];

  age = {
    identityPaths = [ "${config.users.users.${username}.home}/.ssh/id_ed25519" ];
    secrets.nextdns-profile = {
      file = ../../../secrets/nextdns-profile.age;
      mode = "0400";
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 10;
      };
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "i915.enable_guc=2"
      "i915.enable_fbc=1"
      "i915.enable_psr=2"
    ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ username ];
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "t480s";
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          AddressRandomization = "once";
          AddressRandomizationRange = "full";
        };
        Network = {
          EnableIPv6 = true;
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services = {
    nextdns = {
      enable = true;
      arguments = [
        "-config-file"
        config.age.secrets.nextdns-profile.path
        "-report-client-info"
        "-auto-activate"
      ];
    };
    printing.enable = true;
    displayManager = {
      enable = true;
      ly.enable = true;
    };
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    upower.enable = true;
    fwupd.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.nushell;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
    ];
  };

  environment.systemPackages = with pkgs; [ helix ];

  programs = {
    niri.enable = true;
    dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
    dsearch.enable = true;
  };

  system.stateVersion = "26.05";
}
