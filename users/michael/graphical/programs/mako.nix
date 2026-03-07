# base00 = "#282828";
# base01 = "#3C3836";
# base02 = "#504945";
# base03 = "#665C54";
# base04 = "#BDAE93";
# base05 = "#D5C4A1";
# base06 = "#EBDBB2";
# base07 = "#FBF1C7";
# base08 = "#FB4934";
# base09 = "#FE8019";
# base0A = "#FABD2F";
# base0B = "#B8BB26";
# base0C = "#8EC07C";
# base0D = "#83A598";
# base0E = "#D3869B";
# base0F = "#D65D0E";
{config, ...}: {
  services.mako = {
    enable = true;
    settings = with config.colorScheme.palette; {
      default-timeout = 3000;
      ignore-timeout = false;
      sort = "-time";
      layer = "overlay";
      background-color = "#${base00}";
      width = 300;
      height = 100;
      border-size = 2;
      border-color = "#${base03}"; # Main border color
      border-radius = 17;
      icons = true;
      max-icon-size = 64;
      font = "${builtins.head config.fonts.fontconfig.defaultFonts.monospace} 10";
      anchor = "top-right";
      markup = true;
      actions = true; # As per new example, often a good default

      "urgency=low" = {
        border-color = "#${base07}";
      };
      "urgency=normal" = {
        border-color = "#${base09}";
      };
      "urgency=high" = {
        border-color = "#${base08}";
        default-timeout = 0; # This will make high urgency notifications sticky
      };
      "category=mpd1" = {
        default-timeout = 20000;
        group-by = "category"; # In mako config this is a string, not a list.
      };
    };
  };
}
