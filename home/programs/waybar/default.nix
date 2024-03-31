{config, ...}: {
  programs.waybar = {
    enable = true;

    style = ./style.css;

    settings = {
      bar =
        {
          position = "top";
          layer = "top";

          modules-left = [
            "custom/launcher"
            "custom/playerctl"
            "tray"
            "hyprland/workspaces"
            "wlr/taskbar"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "custom/weather"
            "temperature"
            "disk#1"
            "disk#2"
            "disk#3"
            "memory"
            "cpu"
            "network"
            "custom/pacmanAlt"
            "pulseaudio"
            "custom/wlogout"
          ];
        }
        // import ./modules.nix {inherit config;};
    };
  };
}
