# based on https://github.com/zDyanTB/HyprNova/blob/master/.config/hypr/hyprlock.conf
# base00: "#292828"
# base01: "#32302f"
# base02: "#504945"
# base03: "#665c54"
# base04: "#bdae93"
# base05: "#ddc7a1"
# base06: "#ebdbb2"
# base07: "#fbf1c7"
# base08: "#ea6962"
# base09: "#e78a4e"
# base0A: "#d8a657"
# base0B: "#a9b665"
# base0C: "#89b482"
# base0D: "#7daea3"
# base0E: "#d3869b"
# base0F: "#bd6f3e"
{config, ...}: let
  theme = config.colorScheme.palette;
  font_family = builtins.head config.fonts.fontconfig.defaultFonts.monospace;
in {
  programs.hyprlock = {
    enable = true;

    settings = {
      general.hide_cursor = false;

      background = [
        {
          path = "${config.xdg.userDirs.pictures}/wallpapers/fuck you nvidia.png"; # only pngs are supported
          blur_size = 5;
          blur_passes = 3;
        }
      ];

      input-field = [
        {
          monitor = "eDP-1";

          size = "300, 50";

          outline_thickness = 2;

          outer_color = "rgb(${theme.base04})";
          inner_color = "rgb(${theme.base00})";
          font_color = "rgb(${theme.base0D})";

          fade_on_empty = false;
          placeholder_text = ''<span font_family="${font_family}" foreground="##${theme.base0D}">Password...</span>'';

          dots_spacing = 0.3;
          dots_center = true;
        }
      ];

      label = [
        {
          text = "$TIME";
          inherit font_family;
          font_size = 50;
          color = "rgb(${theme.base00})";

          position = "0, 80";

          valign = "center";
          halign = "center";
        }
      ];
    };
  };
}
