{ config, pkgs, ... }:

{
  # imports = [
  #   ./shell/default.nix
  #   ./programs/hyprland.nix
  #   ./programs/waybar.nix
  #   ./programs/starship.nix
  #   ./programs/kitty.nix
  # ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05"; # Please read the docs before changing.

  fonts.fontconfig.enable = true;
  home.pointerCursor =
    let
      getFrom = url: hash: name: {
        gtk.enable = true;
        x11.enable = true;
        name = name;
        size = 24;
        package =
          pkgs.runCommand "moveUp" { } ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.fetchzip {
              url = url;
              hash = hash;
            }}/dist-light $out/share/icons/${name}
          '';
      };
    in
    getFrom
      "https://github.com/vinceliuice/Graphite-cursors/archive/refs/heads/main.zip"
      "sha256-abnCIoPTbhyeWVBLiNjBI2+/6IIQ6I6lS/rvoVrselY="
      "Graphite-cursors-light";

  home.packages = with pkgs; [
    # System
    wezterm
    wl-clipboard
    cliphist
    wdisplays
    pavucontrol
    neofetch

    # Productivity
    firefox
    thunderbird

    # Privacy
    mullvad-vpn

    # Tools
    handbrake
    dupeguru
    gdu
    killall
    inotify-tools
    swww
    grimblast
    hyprpicker
    libnotify
    magic-wormhole
    # textpieces

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
    # (jetbrains.rider.overrideAttrs (old: {
    #   postPatch = old.postPatch + ''
    #     interp="$(cat $NIX_CC/nix-support/dynamic-linker)"
    #     patchelf --set-interpreter $interp plugins/dotCommon/DotFiles/linux-x64/JetBrains.Profiler.PdbServer
    #   '';
    # }))

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
    DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  };

  programs.git = {
    enable = true;
    userName = "Michael Andreas Graversen";
    userEmail = "home@michael-graversen.dk";
    lfs.enable = true;
    extraConfig = {
      credential = {
        credentialStore = "secretservice";
        # helper = "${pkgs.git-credential-manager}/lib/git-credential-manager/git-credential-manager";
        helper = "${pkgs.nur.repos.utybo.git-credential-manager}/bin/git-credential-manager"; # TODO: don't use nur repo
      };
    };
  };

  programs.yt-dlp = {
    enable = true;
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "/launchers/type-1/style-8.rasi";
    # extraConfig = '''';
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
  };

  services.mako = {
    enable = true;
    defaultTimeout = 2000;
  };

  programs.bat = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.btop = {
    enable = true;

  };

  services.syncthing = {
    enable = true;
  };

  services.mpris-proxy.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # TODO setup nix autocomplete
}
