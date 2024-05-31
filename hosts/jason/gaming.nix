{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Enable local network game transfers
    gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

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

  services.supergfxd = {
    enable = true;
    settings = {
      # mode= "VFIO";
      vfio_enable = true;
    };
  };

  boot.kernelParams = ["amd_pstate=active"];

  # boot.kernelPatches = [
  # 	{

  # 	}
  # ];
}
