{
  config,
  pkgs,
  inputs,
  ...
}: {
  # TODO setup nixd autocomplete
  imports = [
    inputs.nix-colors.homeManagerModules.default

    ./core
    ./wm/hyprland
    ./theme
    ./programs
    ./services
    ./defaultApps.nix
  ];

  programs.home-manager.enable = false;

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["JetBrainsMono NF"];
      sansSerif = ["Inter"];
    };
  };

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

  nixpkgs.overlays = [(import ./programs/discord/electron-overlay.nix)];

  programs.thefuck.enable = true;

  lib.hm.gvariant.dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "graphite-light";
    };
  };

  home.packages = with pkgs; [
    # gnome
    nautilus-open-any-terminal
    sushi
    file-roller # GNOME archive manager
    nautilus-python
    (nautilus.overrideAttrs (super: {
      buildInputs =
        super.buildInputs
        ++ (with gst_all_1; [
          gst-plugins-good
          gst-plugins-bad
        ]);
    }))

    # System
    base16-schemes
    kdePackages.xwaylandvideobridge
    wl-clipboard
    pavucontrol
    neofetch

    # Productivity
    distrobox
    obsidian
    xfce.mousepad

    # Privacy
    mullvad-vpn
    bitwarden-cli

    # Tools
    ventoy-full
    xdg-utils
    envsubst
    jq
    tldr
    gdu
    duf
    hyprpicker
    libnotify
    magic-wormhole-rs
    trash-cli
    lazygit
    qrscan
    podman-tui

    # gaming tools
    ryujinx
    pegasus-frontend
    adwsteamgtk
    # prismlauncher
    # modrinth-app
    # sunshine # https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/usage.html#setup

    # Media
    jellyfin-media-player
    # spotify-player
    # g4music
    amberol
    # termusic
    # ncmpcpp
    # feishin
    # ladybird

    # Image viewer
    # geeqie
    pix

    # misc
    pipes-rs

    # Communication
    # vesktop # Discord but with vencord pre-installed
    signal-desktop
    # element-desktop

    # Gaming
    r2modman
    heroic

    # Development
    # dotnet-sdk_8
    dotnetCorePackages.sdk_9_0
    jetbrains.rider
    hoppscotch

    # Fonts
    nerd-fonts.jetbrains-mono
    inter
  ];
}
