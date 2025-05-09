{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
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

  allowedFileFormats = ["jpeg" "jpg" "png" "gif" "pnm" "tga" "tiff" "webp" "bmp" "farbfeld"];
in {
  home.packages = [
    (pkgs.writeShellScriptBin "rofi-wall" ''
      # Set some variables
      wallDir=$1 # NOTE: symlinked folder needs "/" at the end, this is accounted for elsewhere in the script
      cacheDir="$HOME/.cache/wallpapers/"
      rofiCommand="${config.programs.rofi.package}/bin/rofi -dmenu -i -theme ${config.home.homeDirectory}/${config.xdg.configFile."rofi/wallpaper-switcher.rasi".target}"

      # Create cache dir if not exists
      if [ ! -d "$cacheDir" ]; then
      	mkdir -p "$cacheDir"
      fi

      # Convert images in directory and save to cache dir
      ${pkgs.libnotify}/bin/notify-send "Proccesing wallpapers in $wallDir" -t 2200
      for image in "$wallDir"/*.{${lib.concatStringsSep "," allowedFileFormats}}; do
      	if [ -f "$image" ]; then
      		filename=$(basename "$image")
      		if [ ! -f "$cacheDir/$filename" ]; then
      			${pkgs.imagemagick}/bin/magick convert -strip "$image" -thumbnail 500x500^ -gravity center -extent 500x500 "$cacheDir/$filename"
      		fi
      	fi
      done

      # Launch rofi
      wall_selection=$(${pkgs.findutils}/bin/find "$wallDir" -maxdepth 1 -type f \( ${lib.concatMapStringsSep " -o " (x: ''-iname "*.${x}"'') allowedFileFormats} \) -exec basename {} \; | sort | while read -r A; do echo -en "$A\x00icon\x1f""$cacheDir"/"$A\n"; done | $rofiCommand)

      # output information
      OUTPUT_DISPLAY=$(${config.wayland.windowManager.hyprland.package}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.monitor')

      # Set wallpaper
      [[ -n "$wall_selection" ]] || exit 1
      ${pkgs.swww}/bin/swww img "$wallDir"/"$wall_selection" --transition-step 50 --transition-fps 200 --transition-type any --outputs "$OUTPUT_DISPLAY"
      # ${pkgs.lutgen}/bin/lutgen apply -p gruvbox-dark "$wallDir"/"$wall_selection" -o "$HOME/.cache/wallpapers-lut"
      # ${pkgs.swww}/bin/swww img "$HOME/.cache/wallpapers-lut/$wall_selection" --transition-step 255 --transition-type any
      ${pkgs.libnotify}/bin/notify-send "Wallpaper set!" -i "$wallDir"/"$wall_selection" -t 2200
      exit 0
    '')
  ];

  xdg.configFile."rofi/wallpaper-switcher.rasi".text =
    toRasi {
      configuration = {
        modi = "drun";
        show-icons = true;
        drun-display-format = "{name}";
        font = "${builtins.head config.fonts.fontconfig.defaultFonts.monospace} Bold 11";
        matching = "fuzzy";
        levenshtein-sort = false;
        sort = true;
      };
    }
    + (toRasi (import ./theme.nix {inherit config;}));
}
