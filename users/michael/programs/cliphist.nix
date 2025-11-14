{pkgs, ...}: {
  services.cliphist.enable = true; # clipboard support

  wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store" # start clipboard manager
  ];
}
