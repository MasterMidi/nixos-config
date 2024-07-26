{
  inputs,
  config,
  ...
}: {
  imports = [
    ./sops.nix
  ];

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  # add users ssh key
  systemd.user.tmpfiles.rules = [
    "L+ '${config.home.homeDirectory}/.ssh/id_ed25519' - - - - ${config.sops.secrets.SSH_KEY.path}"
    "L+ '${config.home.homeDirectory}/.ssh/id_ed25519.pub' - - - - ${config.sops.secrets.SSH_KEY_PUB.path}"
  ];

  services = {
    swayosd = {
      enable = true;
      # display = "eDP-1";
    };
  };
}
