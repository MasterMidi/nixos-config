{ config, pkgs, inputs, ... }:

{
  imports = [
    ./wm/hyprland.nix
    ./theme
    ./shell
    ./programs
    ./services
    ./keyboard
  ];

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05";
  programs.home-manager.enable = false;

  home.packages = with pkgs; [
    # System
    xwaylandvideobridge
    wl-clipboard
    waypaper
    wdisplays
    pavucontrol
    neofetch
    haskellPackages.kmonad
    gnome3.gnome-tweaks

    # Productivity
    thunderbird
    distrobox

    # Privacy
    mullvad-vpn

    # Tools
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

    # Media
    jellyfin-media-player
    ffmpeg-full
    rhythmbox
    vlc
    spotify
    spotify-player
    # playerctl

    # Communication
    discord
    signal-desktop

    # Gaming
    r2modman
    heroic
    lutris
    winetricks
    wineWowPackages.waylandFull

    # Development
    dotnet-sdk_7
    jetbrains.rider

    # Fonts
    (nerdfonts.override { fonts = [ "Meslo" "FiraCode" ]; })
  ];

  home.file = {
    "Pictures/wallpapers" = {
      # source = ./wallpapers;
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/wallpapers";
    };
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/michael/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
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

    EDITOR = "vscodium";
    TERM_PROGRAM = "kitty";
    BROWSER = "firefox";
    # DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  };

  # TODO setup nix autocomplete
}
