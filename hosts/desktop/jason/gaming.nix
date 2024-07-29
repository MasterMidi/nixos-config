{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
  ];

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    protontricks
    winetricks
    wineWowPackages.waylandFull
    (lutris.override {
      extraPkgs = pkgs: [
        libnghttp2
        winetricks # is this needed?
      ];
    })
  ];

  # Enable steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Enable local network game transfers
    gamescopeSession.enable = true;
    platformOptimizations.enable = true;

    extraCompatPackages = with pkgs; [
      # proton-ge-bin
    ];
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = lib.mkForce true;
    driSupport32Bit = true; # Enables support for 32bit libs that steam uses
    extraPackages = with pkgs; [
      # amdvlk
    ];
    extraPackages32 = with pkgs; [
      # driversi686Linux.amdvlk
    ];
  };

  # Enable gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  users.users.michael = {
    extraGroups = [
      "gamemode"
    ];
  };

  # Enable SuperGFXD
  services.supergfxd = {
    enable = true;
    settings = {
      # mode= "VFIO";
      vfio_enable = true;
    };
  };

  # Enable KVMFR for winows VM
  virtualisation = {
    vfio.enable = false;
    kvmfr = {
      enable = true;
      shm = {
        enable = true;
        size = 64;
        user = "michael";
        group = "libvirtd";
        mode = "0666";
      };
    };
  };
}
