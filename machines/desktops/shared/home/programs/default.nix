{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./discord
    ./mpv
    ./nautilus
    ./rofi
    ./vscodium
    ./waybar
    ./wlogout
    ./bashmount.nix
    ./firefox.nix
    ./fzf.nix
    ./git.nix
    ./hyprlock.nix
    ./kitty.nix
    ./lazygit.nix
    ./ripgrep.nix
    ./spotify.nix
    # ./thunderbird.nix
    ./zathura.nix
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono NF" ];
      sansSerif = [ "Inter" ];
    };
  };

  home.sessionVariables = {
    # Setup XDG
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

    # Misc values
    EDITOR = "nano";
    TERM_PROGRAM = "kitty";
    BROWSER = "firefox";
    FILE_BROWSER = "nautilus";
  };
}
