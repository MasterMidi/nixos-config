{
  pkgs,
  config,
  lib,
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
    terminal = "kitty";
    font = "MesloLGS Nerd Font 10";
    theme = "/theme.rasi";
    # theme = {
    #   "@import" = "theme.rasi";
    #   "*" = with theme.withHashtag; {
    #     background = "${base00}FF";
    #     background-alt = "${base01}FF";
    #     foreground = "${base07}FF";
    #     selected = "${base07}FF";nohup
    #     active = "${base07}FF";
    #     urgent = "${base08}FF";
    #   };
    # };
  };

  home.packages = with pkgs; [
    rofi-systemd
    rofi-rbw-wayland
    rofi-bluetooth
    bitwarden-menu

    (writeShellScriptBin "rofi-wall" (builtins.readFile ./wallpaper-switcher/wall-select.sh))
    (writeShellScriptBin "rofi-games" (builtins.readFile ./gamelauncher/gamelauncher.sh))
    (writeShellScriptBin "rofi-network" (builtins.readFile ./rofi-network-manager/rofi-network-manager.sh))
    (writeShellScriptBin "rofi-bitwarden" (builtins.readFile ./rofi-bitwarden.sh))
    (writeShellScriptBin "rofi-clipboard" (builtins.readFile ./rofi-clipboard.sh))
    (writeShellScriptBin "rofi-emoji" (builtins.readFile ./rofi-emoji.sh))
    (writeShellScriptBin "rofi-kaomoji" (builtins.readFile (
      pkgs.substituteAll {
        src = ./rofi-kaomoji.sh;
        isExecutable = true;

        # Substitutions
        kaomojis = ./kaomoji.txt;
      }
    )))
  ];

  xdg.configFile = {
    # "rofi/colors.rasi".source = ./colors.rasi;
    "rofi/colors.rasi".text = with config.colorScheme.palette; ''
      * {
          background: #${base00};
          background-alt: #${base01};
          foreground: #${base07};
          selected: #${base07};
          active: #${base07};
          urgent: #${base08};
      }'';
    "rofi/theme.rasi".source = ./applauncher/theme.rasi;
    "rofi/wallpaper-switcher.rasi".source = ./wallpaper-switcher/theme.rasi;
    "rofi/gamelauncher.rasi".source = ./gamelauncher/theme.rasi;
    "rofi/rofi-network-manager.rasi".source = ./rofi-network-manager/rofi-network-manager.rasi;
    "rofi/rofi-network-manager.conf".source = ./rofi-network-manager/rofi-network-manager.conf;
  };
}
