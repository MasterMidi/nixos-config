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
  imports = [
    ./wallpaper-switcher
    ./clipboard.nix
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      rofi-calc
      # rofi-emoji
      # rofi-nerdy
    ];
    terminal = config.home.sessionVariables.TERM_PROGRAM;
    font = "${builtins.head config.fonts.fontconfig.defaultFonts.monospace} 10";
    # theme = "/theme.rasi";
    theme = import ./theme.nix {inherit config;};
    extraConfig = {
      modi = "drun,run,ssh";
      show-icons = true;
      icon-theme = config.gtk.iconTheme.name;
      display-drun = " Apps";
      display-run = " Run";
      display-ssh = " SSH";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      matching = "fuzzy";
      levenshtein-sort = false;
      sort = true;
    };
  };

  home.packages = with pkgs; [
    rofi-systemd
    rofi-rbw-wayland
    rofi-bluetooth
    bemoji
    bitwarden-menu

    (writeShellScriptBin "rofi-games" (builtins.readFile ./gamelauncher/gamelauncher.sh))
    (writeShellScriptBin "rofi-network" (builtins.readFile ./rofi-network-manager/rofi-network-manager.sh))
    (writeShellScriptBin "rofi-bitwarden" (builtins.readFile ./rofi-bitwarden.sh))
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
    "rofi/colors.rasi".text = toRasi (import ./colors.nix {inherit config;});

    "rofi/gamelauncher.rasi".source = ./gamelauncher/theme.rasi;
    "rofi/rofi-network-manager.rasi".source = ./rofi-network-manager/rofi-network-manager.rasi;
    "rofi/rofi-network-manager.conf".source = ./rofi-network-manager/rofi-network-manager.conf;
  };
}
