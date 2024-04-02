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

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamemode.enable = true;

  programs.gamescope.enable = true;
}
