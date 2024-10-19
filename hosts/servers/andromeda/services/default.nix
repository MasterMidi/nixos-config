{...}: {
  imports = [
    ./homarr.nix
    # ./mealie.nix
    ./immich.nix
  ];

  users.groups.media = {
    gid = 500;
  };

  users.users.michael.extraGroups = ["media"];
}
