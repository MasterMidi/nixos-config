{pkgs, ...}: {
  services.cliphist.enable = true; # clipboard support
  services.mpris-proxy.enable = true; # media player mpris proxy
  services.playerctld.enable = true; # media player control

  home.packages = with pkgs; [
    playerctl
  ];
}
