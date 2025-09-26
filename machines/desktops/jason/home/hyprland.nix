{pkgs, config,lib, ...}: let
	# monitor = config.facter.report.hardware.monitor |> builtins.head |> lib.findFirst (x: x.type == "monitor") {};
	monitor_xiomi = {
		width = 3440;
		height = 1440;
		vertical_frequency = 120; # 144
	};
  monitor_asus = {
		width = 1920;
		height = 1080;
		vertical_frequency = 75; # 60 pushing it
	};
in{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-2, ${monitor_xiomi.width |> toString}x${monitor_xiomi.height |> toString}@${monitor_xiomi.vertical_frequency |> toString}, 1920x0, 1"
      "HDMI-A-2, ${monitor_asus.width |> toString}x${monitor_asus.height |> toString}@${monitor_asus.vertical_frequency |> toString}, 0x275, 1"
      ];
  };
}
