{ config, ... }:
{
  imports = [
    ../../common
  ];

  sops.secrets = {
    USER_MICHAEL_PASSWORD_HASH = {
      sopsFile = ./secrets/secrets.yaml;
      neededForUsers = true;
    };
    USER_MICHAEL_SSH_KEY = {
      key = "SSH_KEY";
      sopsFile = ./secrets/secrets.yaml;
      owner = config.users.users.michael.name;
      mode = "0600";
      path = "${config.users.users.michael.home}/.ssh/id_ed25519";
    };
    USER_MICHAEL_SSH_KEY_PUB = {
      key = "SSH_KEY_PUB";
      sopsFile = ./secrets/secrets.yaml;
      owner = config.users.users.michael.name;
      mode = "0600";
      path = "${config.users.users.michael.home}/.ssh/id_ed25519.pub";
    };
  };

  users.users.michael = {
    uid = 1000;
    isNormalUser = true;
    description = "Michael Andreas Graversen";
    group = "users";
    hashedPasswordFile = config.sops.secrets.USER_MICHAEL_PASSWORD_HASH.path;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # Add my public SSH key to the authorized_keys of the same user on all machines
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  home-manager.users.michael = {
    home.username = "michael";
    home.homeDirectory = "/home/michael";
    imports = [
      ./programs
    ];
  };
}
