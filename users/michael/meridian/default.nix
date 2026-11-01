{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../graphical
  ];

  home-manager.users.michael = {
    home.stateVersion = "23.11";

    home.packages = with pkgs; [
      # mkvtoolnix
      # subtitleedit
      # subtitlecomposer

      orca-slicer
    ];

    wayland.windowManager.hyprland.settings =
      let
        # monitor = config.facter.report.hardware.monitor |> builtins.head |> lib.findFirst (x: x.type == "monitor") {};
        monitor = {
          width = 2240;
          height = 1400;
          vertical_frequency = 60;
        };

        # hl.dsp.exec_cmd("...") Lua expression for a shell command
        execCmd = cmd: "hl.dsp.exec_cmd(\"${lib.replaceStrings [ "\"" ] [ "\\\"" ] cmd}\")";
      in
      {
        monitor = [
          {
            output = "eDP-1";
            mode = "${monitor.width |> toString}x${monitor.height |> toString}@${
              monitor.vertical_frequency |> toString
            }";
            position = "0x0";
            scale = 1;
          }
        ];
        bind = [
          {
            _args = [
              "XF86AudioMute"
              (lib.generators.mkLuaInline (
                execCmd "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
              ))
            ];
          }
          {
            _args = [
              "XF86AudioLowerVolume"
              (lib.generators.mkLuaInline (
                execCmd "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
              ))
            ];
          }
          {
            _args = [
              "XF86AudioRaiseVolume"
              (lib.generators.mkLuaInline (
                execCmd "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
              ))
            ];
          }
          {
            _args = [
              "XF86AudioMicMute"
              (lib.generators.mkLuaInline (
                execCmd "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
              ))
            ];
          }
          {
            _args = [
              "XF86MonBrightnessDown"
              (lib.generators.mkLuaInline (
                execCmd "${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set 10%-"
              ))
            ];
          }
          {
            _args = [
              "XF86MonBrightnessUp"
              (lib.generators.mkLuaInline (
                execCmd "${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set +10%"
              ))
            ];
          }
        ];
      };
  };
}
