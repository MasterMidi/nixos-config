{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # TODO setup nixd autocomplete
  imports = [
    inputs.nix-colors.homeManagerModules.default

    ./wm/hyprland
    ./theme
    ./programs
    ./services
    ./keyboard
    ./defaultApps.nix
    ./nix.nix
  ];

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05";

  programs.home-manager.enable = false;

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  fonts.fontconfig.enable = true;

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
    FILE_BROWSER = "nautilus";
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

  lib.hm.gvariant.dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "graphite-light";
    };
  };

  home.packages = with pkgs; [
    # gnome
    nautilus-open-any-terminal
    gnome.sushi
    gnome.nautilus-python
    (gnome.nautilus.overrideAttrs (super: {
      buildInputs =
        super.buildInputs
        ++ (with gst_all_1; [
          gst-plugins-good
          gst-plugins-bad
        ]);
    }))

    # System
    base16-schemes
    xwaylandvideobridge
    wl-clipboard
    wdisplays
    pavucontrol
    neofetch
    # haskellPackages.kmonad
    gnome3.gnome-tweaks
    hyprcursor

    # Productivity
    distrobox
    obsidian
    leafpad

    # Privacy
    mullvad-vpn
    bitwarden-cli

    # Tools
    ventoy-full
    xdg-utils
    envsubst
    jq
    tldr
    # handbrake
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
    ydotool
    parabolic
    motrix
    qrscan
    networkmanagerapplet # NetworkManager tray icon

    # gaming tools
    protonup-qt
    adwsteamgtk
    prismlauncher
    modrinth-app

    # Media
    jellyfin-media-player
    ffmpeg-full
    rhythmbox
    vlc
    spotify-player
    sunshine # https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/usage.html#setup
    g4music
    amberol
    termusic
    ncmpcpp

    # Image viewer
    geeqie
    cinnamon.pix
    # loupe

    # misc
    pipes-rs

    # Communication
    vesktop # Discord but with vencord pre-installed
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
