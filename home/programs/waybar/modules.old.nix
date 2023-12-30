{
  "hyprland/workspaces" = {
    "on-click" = "activate";
    "active-only" = false;
    "all-outputs" = true;
    "format" = "{}";
    "format-icons" = {
      "urgent" = "";
      "active" = "";
      "default" = "";
    };
    "persistent-workspaces" = {
      "*" = 5;
    };
  };
  "wlr/taskbar" = {
    "format" = "{icon}";
    "icon-size" = 18;
    "tooltip-format" = "{title}";
    "on-click" = "activate";
    "on-click-middle" = "close";
    "ignore-list" = [ "$TERM_PROGRAM" ];
    "app_ids-mapping" = {
      "firefoxdeveloperedition" = "firefox-developer-edition";
    };
    "rewrite" = {
      "Firefox Web Browser" = "Firefox";
      "Foot Server" = "Terminal";
    };
  };
  "hyprland/window" = {
    "rewrite" = {
      "(.*) - Brave" = "$1";
      "(.*) - $BROWSER" = "$1";
      "(.*) - Brave Search" = "$1";
      "(.*) - Outlook" = "$1";
      "(.*) Microsoft Teams" = "$1";
    };
    "separate-outputs" = true;
  };
  "custom/youtube" = {
    "format" = " {}";
    "exec" = "python ~/private/youtube.py";
    "restart-interval" = 600;
    "on-click" = "$BROWSER https=#studio.youtube.com";
    "tooltip" = false;
  };
  "custom/cliphist" = {
    "format" = "";
    "on-click" = "sleep 0.1 && ~/dotfiles/scripts/cliphist.sh";
    "on-click-right" = "sleep 0.1 && ~/dotfiles/scripts/cliphist.sh d";
    "on-click-middle" = "sleep 0.1 && ~/dotfiles/scripts/cliphist.sh w";
    "tooltip" = false;
  };
  "custom/updates" = {
    "format" = "  {}";
    "tooltip-format" = "{}";
    "escape" = true;
    "return-type" = "json";
    "exec" = "~/dotfiles/scripts/updates.sh";
    "restart-interval" = 60;
    "on-click" = "$TERM_PROGRAM -e ~/dotfiles/scripts/installupdates.sh";
    "on-click-right" = "~/dotfiles/.settings/software.sh";
    "tooltip" = false;
  };
  "custom/wallpaper" = {
    "format" = "";
    "on-click" = "~/dotfiles/hypr/scripts/wallpaper.sh select";
    "on-click-right" = "~/dotfiles/hypr/scripts/wallpaper.sh";
    "tooltip" = false;
  };
  "custom/waybarthemes" = {
    "format" = "";
    "on-click" = "~/dotfiles/waybar/themeswitcher.sh";
    "tooltip" = false;
  };
  "custom/settings" = {
    "format" = "";
    "on-click" = "$TERM_PROGRAM --class dotfiles-floating -e ~/dotfiles/hypr/settings/settings.sh";
    "tooltip" = false;
  };
  "custom/keybindings" = {
    "format" = "";
    "on-click" = "~/dotfiles/hypr/scripts/keybindings.sh";
    "tooltip" = false;
  };
  "custom/filemanager" = {
    "format" = "";
    "on-click" = "~/dotfiles/.settings/filemanager.sh";
    "tooltip" = false;
  };
  "custom/outlook" = {
    "format" = "";
    "on-click" = "$BROWSER --app=https=#outlook.office.com/mail/";
    "tooltip" = false;
  };
  "custom/teams" = {
    "format" = "";
    "on-click" = "$BROWSER --app=https=#teams.microsoft.com/go";
    "tooltip" = false;
  };
  "custom/browser" = {
    "format" = "";
    "on-click" = "~/dotfiles/.settings/browser.sh";
    "tooltip" = false;
  };
  "custom/chatgpt" = {
    "format" = "";
    "on-click" = "$BROWSER --app=https=#chat.openai.com";
    "tooltip" = false;
  };
  "custom/calculator" = {
    "format" = "";
    "on-click" = "qalculate-gtk";
    "tooltip" = false;
  };
  "custom/windowsvm" = {
    "format" = "";
    "on-click" = "~/dotfiles/scripts/launchvm.sh";
    "tooltip" = false;
  };
  "custom/appmenu" = {
    "format" = "Apps";
    "on-click" = "rofi -show drun -replace";
    "on-click-right" = "~/dotfiles/hypr/scripts/keybindings.sh";
    "tooltip" = false;
  };
  "keyboard-state" = {
    "numlock" = true;
    "capslock" = true;
    "format" = "{name} {icon}";
    "format-icons" = {
      "locked" = "";
      "unlocked" = "";
    };
  };
  "tray" = {
    "spacing" = 10;
  };
  "clock" = {
    "tooltip-format" = "<big>{=%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    "format-alt" = "{=%Y-%m-%d}";
  };
  "custom/system" = {
    "format" = "";
    "tooltip" = false;
  };
  "cpu" = {
    "format" = "/ C {usage}% ";
    "on-click" = "$TERM_PROGRAM -e htop";
  };
  "memory" = {
    "format" = "/ M {}% ";
    "on-click" = "$TERM_PROGRAM -e htop";
  };
  "disk" = {
    "interval" = 30;
    "format" = "D {percentage_used}% ";
    "path" = "/";
    "on-click" = "$TERM_PROGRAM -e htop";
  };
  "hyprland/language" = {
    "format" = "/ K {short}";
  };
  "group/hardware" = {
    "orientation" = "inherit";
    "drawer" = {
      "transition-duration" = 300;
      "children-class" = "not-memory";
      "transition-left-to-right" = false;
    };
    "modules" = [ "custom/system" "disk" "cpu" "memory" "hyprland/language" ];
  };
  "group/settings" = {
    "orientation" = "inherit";
    "drawer" = {
      "transition-duration" = 300;
      "children-class" = "not-memory";
      "transition-left-to-right" = false;
    };
    "modules" = [ "custom/settings" "custom/waybarthemes" "custom/wallpaper" ];
  };
  "group/quicklinks" = {
    "orientation" = "horizontal";
    "modules" = [ "custom/filemanager" "custom/browser" ];
  };
  "network" = {
    "format" = "{ifname}";
    "format-wifi" = "   {signalStrength}%";
    "format-ethernet" = "  {ipaddr}";
    "format-disconnected" = "Not connected";
    "tooltip-format" = " {ifname} via {gwaddri}";
    "tooltip-format-wifi" = "   {essid} ({signalStrength}%)";
    "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
    "tooltip-format-disconnected" = "Disconnected";
    "max-length" = 50;
    "on-click" = "~/dotfiles/.settings/networkmanager.sh";
  };
  "pulseaudio" = {
    "format" = "{icon} {volume}%";
    "format-bluetooth" = "{volume}% {icon} {format_source}";
    "format-bluetooth-muted" = " {icon} {format_source}";
    "format-muted" = " {format_source}";
    "format-source" = "{volume}% ";
    "format-source-muted" = "";
    "format-icons" = {
      "headphone" = "";
      "hands-free" = "";
      "headset" = "";
      "phone" = "";
      "portable" = "";
      "car" = "";
      "default" = [ "" " " " " ];
    };
    "on-click" = "pavucontrol";
  };
  "user" = {
    "format" = "{user}";
    "interval" = 60;
    "icon" = false;
  };
  "idle_inhibitor" = {
    "format" = "{icon}";
    "tooltip" = false;
    "format-icons" = {
      "activated" = "Auto lock OFF";
      "deactivated" = "ON";
    };
  };
}
