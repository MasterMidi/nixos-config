{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    (writeShellScriptBin "rofi-games" ''
      # set variables
      ScrDir=`dirname "$(realpath "$0")"`
      RofiConf="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/gamelauncher.rasi"


      # set steam library
      SteamLib="''${XDG_DATA_HOME:-$HOME/.local/share}/Steam/config/libraryfolders.vdf"
      SteamThumb="''${XDG_DATA_HOME:-$HOME/.local/share}/Steam/appcache/librarycache"

      if [ ! -f $SteamLib ] || [ ! -d $SteamThumb ] || [ ! -f $RofiConf ] ; then
          ${pkgs.libnotify}/bin/notify-send "t1" -a "Steam library not found!" -r 91190 -t 2200
          exit 1
      fi


      # check steam mount paths
      SteamPaths=`grep '"path"' $SteamLib | awk -F '"' '{print $4}'`
      ManifestList=`find $SteamPaths/steamapps/ -type f -name "appmanifest_*.acf" 2>/dev/null`


      # set rofi override
      elem_border=$(( hypr_border * 2 ))
      icon_border=$(( elem_border - 3 ))
      r_override="element{border-radius:''${elem_border}px;} element-icon{border-radius:''${icon_border}px;}"


      # read intalled games
      GameList=$(echo "$ManifestList" | while read acf
      do
          appid=`grep '"appid"' $acf | cut -d '"' -f 4`
          if [ -f ''${SteamThumb}/''${appid}_library_600x900.jpg ] ; then
              game=`grep '"name"' $acf | cut -d '"' -f 4`
              echo "$game|$appid"
          else
              continue
          fi
      done | sort)


      # launch rofi menu
      RofiSel=$( echo "$GameList" | while read acf
      do
          appid=`echo $acf | cut -d '|' -f 2`
          game=`echo $acf | cut -d '|' -f 1`
          echo -en "$game\x00icon\x1f''${SteamThumb}/''${appid}_library_600x900.jpg\n"
      done | ${config.programs.rofi.package}/bin/rofi -dmenu -i  -config $RofiConf)


      # launch game
      if [ ! -z "$RofiSel" ] ; then
          launchid=`echo "$GameList" | grep "$RofiSel" | cut -d '|' -f 2`
          steam -applaunch "''${launchid} [gamemoderun %command%]" &
          ${pkgs.libnotify}/bin/notify-send "Launching ''${RofiSel}..." -i ''${SteamThumb}/''${launchid}_header.jpg -t 2200
      fi
    '')
  ];
}
