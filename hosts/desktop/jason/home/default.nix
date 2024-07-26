{inputs, ...}: {
  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  services = {
    swayosd = {
      enable = true;
      # display = "eDP-1";
    };
  };
}
