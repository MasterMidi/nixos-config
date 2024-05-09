{config, ...}: {
  "custom/launcher" = {
    format = "";
    # on-click = "$TERM_PROGRAM -e '$FILE_BROWSER'";
    on-click = "kitty --hold bash -c 'yazi'"; # TODO: use env variables if possible
    tooltip = false;
  };

  "custom/playerctl" = {
    format = "{icon} {}";
    return-type = "json";
    max-length = 56;
    exec = "playerctl --player=spotify_player -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
    on-click = "playerctl --player=spotify_player play-pause";
    on-click-middle = "playerctl --player=spotify_player previous";
    on-click-right = "playerctl --player=spotify_player next";
    on-scroll-up = "playerctl --player=spotify_player volume 0.05+";
    on-scroll-down = "playerctl --player=spotify_player volume 0.05-";
    format-icons = {
      Playing = "<span foreground='#46c880'>󰁙 </span>";
      Paused = "<span foreground='#cdd6f4'>󰏥 </span>";
    };
  };

  "custom/player" = {
    format = "{icon} {}";
    return-type = "json";
    max-length = 56;
    exec = "playerctl --player=spotify_player -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
    on-click = "playerctl --player=spotify_player play-pause";
    on-click-middle = "playerctl --player=spotify_player previous";
    on-click-right = "playerctl --player=spotify_player next";
    on-scroll-up = "playerctl --player=spotify_player volume 0.05+";
    on-scroll-down = "playerctl --player=spotify_player volume 0.05-";
    format-icons = {
      spotify_player = "<span foreground='#46c880'> </span>";
      Default = "<span foreground='#cdd6f4'>󰫔 </span>";
    };
  };

  tray = {
    icon-size = 16;
    spacing = 8;
  };

  "hyprland/workspaces" = {
    on-click = "activate";
    active-only = false;
    all-outputs = true;
    format = "{}";
    format-icons = {
      urgent = "";
      active = "";
      default = "";
    };
    persistent-workspaces = {
      "*" = 5;
    };
  };

  "wlr/taskbar" = {
    format = "{icon}";
    icon-size = 24;
    icon-theme = config.gtk.iconTheme.name; # "Colloid";
    tooltip-format = "{title}";
    active-first = "false";
    on-click = "activate";
    on-click-middle = "close";
    on-click-right = "minimize";
    ignore-list = ["thunar" "Cavalier" "Tilix" "Character Map" "Settings" "GNOME Tweaks" "Terminal" "Calculator" "conky (arch1)" "blackbox"];
  };

  clock = {
    interval = 1;
    format = "󰃰 {:%B %d  %H:%M:%S}";
    format-alt = " {:%H:%M}";
    on-click-middle = "thunderbird -calendar"; # TODO: find new calendar app (cli based?)
    tooltip-format = "\n<span size='14pt' font='MesloLGS Nerd Font'>{calendar}</span>";
    calendar = {
      mode = "month";
      mode-mon-col = 3;
      on-scroll = 1;
      on-click-right = "mode";
      format = {
        months = "<span color='#5e81ac'><b>{}</b></span>";
        days = "<span color='#88c0d0'><b>{}</b></span>";
        weekdays = "<span color='#d08770'><b>{}</b></span>";
        today = "<span color='#bf616a'><b><u>{}</u></b></span>";
      };
    };
  };

  "custom/weather" = {
    format = "{}";
    exec = ./scripts/weather.sh;
    interval = 3600;
    tooltip = false;
  };

  temperature = {
    critical-threshold = 80;
    format-critical = "<span color='#bf616a'>{icon} {temperatureC}°C</span>";
    format = "{icon} {temperatureC}°C";
    format-icons = ["" "" "" "" ""];
    tooltip = false;
    interval = 2;
  };

  "disk#1" = {
    format = "󰋊 {percentage_used}%";
    format-alt = "󰋊 {used}/{total} GiB";
    states = {
      good = 0;
      warning = 70;
      critical = 95;
    };
    interval = 20;
    path = "/";
  };

  "disk#2" = {
    format = "󰋊 {percentage_used}%";
    format-alt = "󰋊 {used}/{total} GiB";
    states = {
      good = 0;
      warning = 70;
      critical = 95;
    };
    interval = 20;
    path = "/nix";
  };

  "disk#3" = {
    format = "󰋊 {percentage_used}%";
    format-alt = "󰋊 {used}/{total} GiB";
    states = {
      good = 0;
      warning = 70;
      critical = 95;
    };
    interval = 20;
    path = "/home";
  };

  memory = {
    format = " {}%";
    format-alt = " {used}/{total} GiB";
    interval = 5;
  };

  cpu = {
    format = "󰍛 {usage}%";
    format-alt = "󰍛 {avg_frequency} GHz";
    interval = 5;
  };

  network = {
    format-wifi = "  {essid} ({signalStrength}%)";
    format-ethernet = "󰈀 {ifname}";
    format-linked = "󰈀 {ifname} (No IP)";
    format-disconnected = "⚠ Disconnected";
    format-alt = "{ifname}: {ipaddr}/{cidr}";

    tooltip-format = "{ifname} via {gwaddr}";
    tooltip-format-wifi = "{ifname}: {ipaddr}/{cidr}, {essid} ({signalStrength}%)";
    tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
  };

  bluetooth = {
    format = " {status}";
    format-disabled = "";
    format-off = "";
    interval = 30;
    on-click = "blueman-manager";
  };

  pulseaudio = {
    format = "<span size='12000'>{icon}</span> {volume}%";
    format-muted = "<span size='12000' foreground='#ff7eb6'></span> {volume}% {format_source}";
    format-bluetooth = "{volume}% {icon} {format_source}";
    format-bluetooth-muted = "󰅶 {icon} {format_source}";
    format-source = "{volume}% ";
    format-source-muted = "";
    format-icons = {
      headphone = "";
      hands-free = "";
      headset = "";
      phone = "";
      portable = "";
      car = "";
      default = ["" "" ""];
    };
    on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
    on-click-right = "pavucontrol";
  };

  battery = {
    states = {
      warning = 30;
      critical = 15;
    };
    format = "{icon}   {capacity}%";
    format-charging = "  {capacity}%";
    format-plugged = "  {capacity}%";
    format-alt = "{icon}  {time}";
    format-icons = [" " " " " " " " " "];
  };

  "custom/wlogout" = {
    format = "";
    on-click = "wlogout -p xdg -b 2 -T 300 -B 300 -R 800 -L 800";
    tooltip = false;
  };
}
