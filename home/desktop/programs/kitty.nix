{config, ...}: {
  programs.kitty = {
    enable = true;
    shellIntegration.enableBashIntegration = false; # When true, makes starship fail on first load for some reason
    # theme = "Gruvbox Material Dark Hard";
    font = {
      name = "${builtins.head config.fonts.fontconfig.defaultFonts.monospace}";
      size = 11;
    };
    settings = with config.colorScheme.palette; rec {
      confirm_os_window_close = 0;

      color0 = "#${base00}";
      color1 = "#${base08}";
      color2 = "#${base0B}";
      color3 = "#${base0A}";
      color4 = "#${base0D}";
      color5 = "#${base0E}";
      color6 = "#${base0C}";
      color7 = "#${base05}";
      color8 = "#${base03}";
      color9 = "#${base08}";
      color10 = "#${base0B}";
      color11 = "#${base0A}";
      color12 = "#${base0D}";
      color13 = "#${base0E}";
      color14 = "#${base0C}";
      color15 = "#${base07}";
      color16 = "#${base09}";
      color17 = "#${base0F}";
      color18 = "#${base01}";
      color19 = "#${base02}";
      color20 = "#${base04}";
      color21 = "#${base06}";

      background = "#${base00}";
      foreground = "#${base05}";

      selection_background = foreground;
      selection_foreground = background;

      cursor = "#${base04}";
      cursor_text_color = background;
    };
  };
}
