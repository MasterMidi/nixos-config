{pkgs, ...}: {
  home-manager.users.michael.imports = [
    ./hyprland
    ./programs
    ./services
    ./theme
    ./default-apps.nix
  ];

  services.mpris-proxy.enable = true; # media player mpris proxy
  services.playerctld.enable = true; # media player control

  home.packages = with pkgs; [
    playerctl
  ];
}
