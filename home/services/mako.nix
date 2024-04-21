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
  services.mako = with config.colorScheme.palette; {
    enable = true;
    defaultTimeout = 3000;
    ignoreTimeout = false; # set to true to only use defaut timeout
    sort = "-time";
    layer = "overlay";
    backgroundColor = "#${base00}";
    width = 300;
    height = 100;
    borderSize = 2;
    borderColor = "#${base03}";
    borderRadius = 17;
    icons = true;
    maxIconSize = 64;
    font = "MesloLGS Nerd Font 10";
    anchor = "top-right";
    markup = true;

    # TODO add urgencies like mako.urgency.low.borderColor = "#...";
    # TODO make custom override to set this in a nix fasion
    # like mako.category.<name>.defaultTimeout = 20000;
    extraConfig = ''
      [urgency=low]
      border-color=#${base07}

      [urgency=normal]
      border-color=#${base09}

      [urgency=high]
      border-color=#${base08}
      default-timeout=0

      [category=mpd]
      default-timeout=20000
      group-by=category
    '';
  };
}
