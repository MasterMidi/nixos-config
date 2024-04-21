{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.lib.formats.rasi) mkLiteral;
  mkValueString = value:
    if isBool value
    then
      if value
      then "true"
      else "false"
    else if isInt value
    then toString value
    else if (value._type or "") == "literal"
    then value.value
    else if isString value
    then ''"${value}"''
    else if isList value
    then "[ ${strings.concatStringsSep "," (map mkValueString value)} ]"
    else abort "Unhandled value type ${builtins.typeOf value}";

  mkKeyValue = {
    sep ? ": ",
    end ? ";",
  }: name: value: "${name}${sep}${mkValueString value}${end}";

  mkRasiSection = name: value:
    if isAttrs value
    then let
      toRasiKeyValue = generators.toKeyValue {mkKeyValue = mkKeyValue {};};
      # Remove null values so the resulting config does not have empty lines
      configStr = toRasiKeyValue (filterAttrs (_: v: v != null) value);
    in ''
      ${name} {
      ${configStr}}
    ''
    else
      (mkKeyValue {
          sep = " ";
          end = "";
        }
        name
        value)
      + "\n";

  toRasi = attrs:
    concatStringsSep "\n" (concatMap (mapAttrsToList mkRasiSection) [
      (filterAttrs (n: _: n == "@theme") attrs)
      (filterAttrs (n: _: n == "@import") attrs)
      (removeAttrs attrs ["@theme" "@import"])
    ]);

  locationsMap = {
    center = 0;
    top-left = 1;
    top = 2;
    top-right = 3;
    right = 4;
    bottom-right = 5;
    bottom = 6;
    bottom-left = 7;
    left = 8;
  };

  primitive = with types; (oneOf [str int bool rasiLiteral]);

  # Either a `section { foo: "bar"; }` or a `@import/@theme "some-text"`
  configType = with types; (either (attrsOf (either primitive (listOf primitive))) str);

  rasiLiteral =
    types.submodule {
      options = {
        _type = mkOption {
          type = types.enum ["literal"];
          internal = true;
        };

        value = mkOption {
          type = types.str;
          internal = true;
        };
      };
    }
    // {
      description = "Rasi literal string";
    };
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      rofi-calc
      # rofi-emoji
      # rofi-nerdy
    ];
    terminal = "kitty";
    font = "MesloLGS Nerd Font 10";
    # theme = "/theme.rasi";
    theme = {
      configuration = {
        modi = "drun,run,ssh";
        show-icons = true;
        icon-theme = "MoreWaita";
        display-drun = " Apps";
        display-run = " Run";
        display-filebrowser = " Files";
        display-window = " Windows";
        display-ssh = " SSH";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
        matching = "fuzzy";
        levenshtein-sort = false;
        sort = true;
      };

      "*" = with config.colorScheme.palette; {
        background = mkLiteral "#${base00}";
        background-alt = mkLiteral "#${base01}";
        foreground = mkLiteral "#${base07}";
        selected = mkLiteral "#${base07}";
        active = mkLiteral "#${base07}";
        urgent = mkLiteral "#${base08}";

        border-colour = "var(selected)";
        handle-colour = "var(selected)";
        background-colour = "var(background)";
        foreground-colour = "var(foreground)";
        alternate-background = "var(background-alt)";
        normal-background = "var(background)";
        normal-foreground = "var(foreground)";
        urgent-background = "var(urgent)";
        urgent-foreground = "var(background)";
        active-background = "var(active)";
        active-foreground = "var(background)";
        selected-normal-background = "var(selected)";
        selected-normal-foreground = "var(background)";
        selected-urgent-background = "var(active)";
        selected-urgent-foreground = "var(background)";
        selected-active-background = "var(urgent)";
        selected-active-foreground = "var(background)";
        alternate-normal-background = "var(background)";
        alternate-normal-foreground = "var(foreground)";
        alternate-urgent-background = "var(urgent)";
        alternate-urgent-foreground = "var(background)";
        alternate-active-background = "var(active)";
        alternate-active-foreground = "var(background)";
      };
    };
  };

  home.packages = with pkgs; [
    rofi-systemd
    rofi-rbw-wayland
    rofi-bluetooth
    bemoji
    bitwarden-menu

    (writeShellScriptBin "rofi-wall" (builtins.readFile ./wallpaper-switcher/wall-select.sh))
    (writeShellScriptBin "rofi-games" (builtins.readFile ./gamelauncher/gamelauncher.sh))
    (writeShellScriptBin "rofi-network" (builtins.readFile ./rofi-network-manager/rofi-network-manager.sh))
    (writeShellScriptBin "rofi-bitwarden" (builtins.readFile ./rofi-bitwarden.sh))
    (writeShellScriptBin "rofi-clipboard" (builtins.readFile ./rofi-clipboard.sh))
    # (writeShellScriptBin "rofi-emoji" (builtins.readFile ./rofi-emoji.sh))
    # (writeShellScriptBin "rofi-kaomoji" (builtins.readFile (
    #   pkgs.substituteAll {rofi-emoji
    #     src = ./rofi-kaomoji.sh;
    #     isExecutable = true;

    #     # Substitutions
    #     kaomojis = ./kaomoji.txt;
    #   }
    # )))
  ];

  xdg.configFile = {
    "rofi/colors.rasi".text = toRasi {
      "*" = with config.colorScheme.palette; {
        background = mkLiteral "#${base00}";
        background-alt = mkLiteral "#${base01}";
        foreground = mkLiteral "#${base07}";
        selected = mkLiteral "#${base07}";
        active = mkLiteral "#${base07}";
        urgent = mkLiteral "#${base08}";
      };
    };
    # "rofi/theme.rasi".source = ./applauncher/theme.rasi;
    "rofi/wallpaper-switcher.rasi".source = ./wallpaper-switcher/theme.rasi;
    "rofi/gamelauncher.rasi".source = ./gamelauncher/theme.rasi;
    "rofi/rofi-network-manager.rasi".source = ./rofi-network-manager/rofi-network-manager.rasi;
    "rofi/rofi-network-manager.conf".source = ./rofi-network-manager/rofi-network-manager.conf;
  };
}
