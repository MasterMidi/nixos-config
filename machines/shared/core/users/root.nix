{ ... }:
{
  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
    ];
  };

  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = "/root";
  };
}
