{ ... }:
{
  imports = [
    ./discord
    ./hyprland
    ./mpv
    ./nautilus
    ./rofi
    ./vscodium
    ./waybar
    ./wlogout
    ./firefox.nix
    ./hyprlock.nix
    ./kitty.nix
    ./spotify.nix
    # ./thunderbird.nix
    ./zathura.nix
    ./cliphist.nix
    ./mako.nix
    ./hypridle.nix
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono NF" ];
      sansSerif = [ "Inter" ];
    };
  };

  home.sessionVariables = {
    TERM_PROGRAM = "kitty";
    BROWSER = "firefox";
    FILE_BROWSER = "nautilus";
  };
}
