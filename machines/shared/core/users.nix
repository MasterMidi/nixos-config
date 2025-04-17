{...}: {
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Andreas Graversen";
    uid = 1000;
    group = "users";
    password = "Servurb42";

    # Add my public SSH key to the authorized_keys of the same user on all machines
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
    ];
  };

  users.users.root = {
    password = "Servurb42";
  };
}
