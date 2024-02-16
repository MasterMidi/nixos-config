{
  pkgs,
  config,
  lib,
  theme,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      # rofi-nerdy
    ];
    # terminal = "$BROWSER";
    font = "MesloLGS Nerd Font 10";
    theme = "/theme.rasi";
    # theme = {
    #   "@import" = "theme.rasi";
    #   "*" = with theme.withHashtag; {
    #     background = "${base00}FF";
    #     background-alt = "${base01}FF";
    #     foreground = "${base07}FF";
    #     selected = "${base07}FF";
    #     active = "${base07}FF";
    #     urgent = "${base08}FF";
    #   };
    # };
  };

  xdg.configFile = {
    # "rofi/colors.rasi".source = ./colors.rasi;
    "rofi/colors.rasi".text = with theme.withHashtag; ''
      * {
          background: ${base00};
          background-alt: ${base01};
          foreground: ${base07};
          selected: ${base07};
          active: ${base07};
          urgent: ${base08};
      }'';
    "rofi/theme.rasi".source = ./applauncher/theme.rasi;

    "rofi/wallpaper-switcher.sh".source = ./wallpaper-switcher/wall-select.sh;
    "rofi/wallpaper-switcher.rasi".source = ./wallpaper-switcher/theme.rasi;

    "rofi/gamelauncher.sh".source = ./gamelauncher/gamelauncher.sh;
    "rofi/gamelauncher.rasi".source = ./gamelauncher/theme.rasi;
  };
}
#TODO: create windows + v copy history rofi menu

