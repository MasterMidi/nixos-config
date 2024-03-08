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
{
  inputs,
  config,
  theme,
  ...
}: let
  c = config.colorScheme.palette;
  font_family = "MesloLGS NF";
in {
  imports = [inputs.hyprlock.homeManagerModules.default];

  programs.hyprlock = {
    enable = true;

    general.hide_cursor = false;

    backgrounds = [
      {
        path = "${config.xdg.userDirs.pictures}/wallpapers/anime girl closeup whitehair blueeyes.png"; # only pngs are supported
        blur_size = 5;
        blur_passes = 3;
      }
    ];

    input-fields = [
      {
        monitor = "DP-1";

        size = {
          width = 300;
          height = 50;
        };

        outline_thickness = 2;

        outer_color = "rgb(${c.base04})";
        inner_color = "rgb(${c.base00})";
        font_color = "rgb(${c.base0D})";

        fade_on_empty = false;
        placeholder_text = ''<span font_family="${font_family}" foreground="##${c.base0D}">Password...</span>'';

        dots_spacing = 0.3;
        dots_center = true;
      }
    ];

    labels = [
      {
        text = "$TIME";
        inherit font_family;
        font_size = 50;
        color = "rgb(${c.base00})";

        position = {
          x = 0;
          y = 80;
        };

        valign = "center";
        halign = "center";
      }
    ];
  };
}
