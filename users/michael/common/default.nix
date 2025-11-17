{ pkgs, inputs, ... }:
{
  imports = [
    ../../common
  ];

  users.users.michael = {
    uid = 1000;
    isNormalUser = true;
    description = "Michael Andreas Graversen";
    group = "users";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # Add my public SSH key to the authorized_keys of the same user on all machines
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
    ];
  };

  home-manager.users.michael = {
    home.username = "michael";
    home.homeDirectory = "/home/michael";
    imports = [
      ./programs
      ./secrets
      ./theme
    ];
  };
}
