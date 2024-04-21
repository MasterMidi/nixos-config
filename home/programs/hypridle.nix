{
  pkgs,
  inputs,
  ...
}: let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in {
  imports = [inputs.hypridle.homeManagerModules.default];

  services.hypridle = {
    enable = true;
    lockCmd = "pidof hyprlock || hyprlock";
    beforeSleepCmd = "loginctl lock-session";
    afterSleepCmd = "hyprctl dispatch dpms on";
    listeners = [
      {
        timeout = 30; # 2.5min.
        onTimeout = "${brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
        onResume = "${brightnessctl} -r"; # monitor backlight restore.
      }

      # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
      {
        timeout = 5; # 2.5min.
        onTimeout = "${brightnessctl} -sd platform::kbd_backlight set 0"; # turn off keyboard backlight.
        onResume = "${brightnessctl} -rd platform::kbd_backlight"; # turn on keyboard backlight.
      }

      {
        timeout = 300; # 5min
        onTimeout = "loginctl lock-session"; # lock screen when timeout has passed
      }

      {
        timeout = 330; # 5.5min
        onTimeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        onResume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
      }

      {
        timeout = 1800; # 30min
        onTimeout = "systemctl suspend"; # suspend pc
      }
    ];
  };
}
