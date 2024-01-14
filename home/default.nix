{
  config,
  pkgs,
  inputs,
  ...
}: {
  # TODO setup nixd autocomplete
  imports = [
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
      # source = ./wallpapers;
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/wallpapers";
    };
  };

  nixpkgs.overlays = [(import ./programs/discord/electron-overlay.nix)];

  # Manage keyboard layouts
  # home.keyboard = {

  # };

  programs.thefuck.enable = true;

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

    #rofi
    rofi-vpn
    rofi-systemd
    rofi-rbw-wayland
    rofi-bluetooth
    rofi-power-menu

    # Productivity
    thunderbird
    distrobox

    # Privacy
    mullvad-vpn
    bitwarden-cli
    rbw

    # Tools
    envsubst
    jq
    handbrake
    dupeguru
    gdu
    duf
    killall
    inotify-tools
    swww
    grimblast
    hyprpicker
    libnotify
    magic-wormhole
    trash-cli
    imagemagick

    # Media
    jellyfin-media-player
    ffmpeg-full
    rhythmbox
    vlc
    spotify
    spotify-player
    sunshine
    g4music

    # Image viewer
    geeqie
    cinnamon.pix
    # loupe

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
