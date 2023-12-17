{ config, pkgs, inputs, ... }:

{
  imports = [
    ./wm
    ./theme
    ./shell
    ./programs
    ./services
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05"; # Please read the docs before changing.
  programs.home-manager.enable = false; # Let Home Manager install and manage itself.

  home.packages = with pkgs; [
    # System
    wezterm
    xwaylandvideobridge
    wl-clipboard
    cliphist
    wdisplays
    pavucontrol
    neofetch
    haskellPackages.kmonad

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

    # Media
    jellyfin-media-player
    ffmpeg-full
    rhythmbox
    vlc
    spotify
    spotify-player
    playerctl

    # Gaming
    discord
    r2modman
    heroic
    lutris
    winetricks
    wineWowPackages.waylandFull

    # Development
    jetbrains.rider

    # Fonts
    (nerdfonts.override { fonts = [ "Meslo" "FiraCode" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = { };


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

    EDITOR = "nano";
    BROWSER = "firefox";
    # DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  };

  # TODO setup nix autocomplete
}
