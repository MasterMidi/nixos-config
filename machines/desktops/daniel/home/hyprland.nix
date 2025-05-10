{pkgs, config,lib, ...}: let
	# monitor = config.facter.report.hardware.monitor |> builtins.head |> lib.findFirst (x: x.type == "monitor") {};
	monitor = {
		width = 2240;
		height = 1400;
		vertical_frequency = 60;
	};
in{
  wayland.windowManager.hyprland.settings = {
    monitor = ["eDP-1, ${monitor.width |> toString}x${monitor.width |> toString}@${monitor.vertical_frequency |> toString}, 0x0, 1"];
    bind = [
      ",XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ",XF86AudioVolumeDown, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
      ",XF86AudioVolumeUp, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
      ",XF86AudioMicMute, exec, ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
      ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set 10%-"
      ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set +10%"
    ];
  };
}
