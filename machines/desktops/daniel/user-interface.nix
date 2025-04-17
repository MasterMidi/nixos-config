{pkgs, ...}: {
  # Login manager
  services.xserver.displayManager.gdm.enable = true;

  # Main Graphical user interface
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # For XWayland support i think
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";
}
