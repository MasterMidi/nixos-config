{
  config,
  pkgs,
  inputs,
  theme,
  lib,
  nix-colors,
  ...
}: {
  # TODO setup nixd autocomplete
  imports = [
    nix-colors.homeManagerModules.default

    ./wm/hyprland
    ./theme
    ./shell
    ./programs
    ./services
    ./keyboard
    ./defaultApps.nix
  ];

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05";

  programs.home-manager.enable = false;

  colorScheme = nix-colors.colorSchemes.gruvbox-material-dark-medium;

  home.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";
    XDG_DESKTOP_DIR = "$HOME/Desktop";
    XDG_DOWNLOAD_DIR = "$HOME/Downloads";
    XDG_TEMPLATES_DIR = "$HOME/Templates";
    XDG_PUBLICSHARE_DIR = "$HOME/Public";
    XDG_DOCUMENTS_DIR = "$HOME/Documents";
    XDG_MUSIC_DIR = "$HOME/Music";
    XDG_PICTURES_DIR = "$HOME/Pictures";
    XDG_VIDEOS_DIR = "$HOME/Videos";

    EDITOR = "nano";
    TERM_PROGRAM = "kitty";
    BROWSER = "firefox";
    FILE_BROWSER = "yazi";
  };

  home.file = {
    "Pictures/wallpapers" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/home/wallpapers";
    };
  };

  nixpkgs.overlays = [(import ./programs/discord/electron-overlay.nix)];

  # Manage keyboard layouts
  # home.keyboard = {

  # };

  programs.thefuck.enable = true;

  xdg.configFile."Vencord/settings/quickCss.css".text = theme.discordCss;

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/video/netflix/default.nix#L17
  # https://github.com/mathix420/free-the-web-apps/blob/master/apps/youtube-music/youtube-music.desktop
  # https://www.reddit.com/r/unixporn/comments/1aup8kn/oc_unleash_the_power_of_web_apps_forget_about/
  xdg.desktopEntries.youtube-music = {
    type = "Application";
    name = "Youtube Music";
    genericName = "Music player";
    comment = "A new music service with official albums, singles, videos, remixes, live performances and more for Android, iOS and desktop. It's all here.";
    exec = "${pkgs.google-chrome}/bin/${pkgs.google-chrome.meta.mainProgram} --app=https://music.youtube.com/ --no-first-run --no-default-browser-check --no-crash-upload \"\\$@\""; # TODO: switch to ungoogled-chromium
    # icon = ./youtube-music.png;
    icon = pkgs.fetchurl {
      name = "youtube-music-icon.png";
      url = "https://music.youtube.com/img/favicon_144.png"; # TODO: find higher res source or just save in repo
      sha256 = "sha256-xuHQU1LBXb8ATf7uZ+Jz/xnASyzWlMkBfJgn6NjZz1Y=";
      meta.license = lib.licenses.unfree;
    };
    categories = ["AudioVideo" "Player"];
    startupNotify = true;
    settings = {
      StartupWMClass = "youtube-music";
    };
  };

  home.packages = with pkgs; [
    # System
    base16-schemes
    xwaylandvideobridge
    wl-clipboard
    wdisplays
    pavucontrol
    neofetch
    haskellPackages.kmonad
    gnome3.gnome-tweaks

    # Productivity
    thunderbird
    distrobox
    obsidian

    # Privacy
    mullvad-vpn
    # bitwarden-cli

    # Tools
    envsubst
    jq
    fzf
    tldr
    handbrake
    # dupeguru
    gdu
    duf
    killall
    inotify-tools
    swww
    grimblast
    hyprpicker
    libnotify
    magic-wormhole-rs
    trash-cli
    imagemagick
    lazygit
    lazydocker
    etcher
    ydotool
    parabolic
    motrix
    qrscan

    # Media
    jellyfin-media-player
    ffmpeg-full
    rhythmbox
    vlc
    spotify
    spotify-player
    sunshine # https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/usage.html#setup
    g4music
    termusic
    ncmpcpp

    # Image viewer
    geeqie
    cinnamon.pix
    # loupe

    # Communication
    # vesktop # Discord but with vencord pre-installed
    (discord.override {
      withVencord = true;
    })
    signal-desktop
    element-desktop

    # Gaming
    r2modman
    heroic

    # Development
    dotnet-sdk_7
    jetbrains.rider

    # Fonts
    (nerdfonts.override {fonts = ["Meslo" "FiraCode"];})
  ];
}
