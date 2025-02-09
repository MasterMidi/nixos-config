{...}: {
  imports = [
    ./cloudflared.nix
    # ./mealie.nix
  ];

  users.groups.media = {
    gid = 500;
  };

  users.users.michael.extraGroups = ["media"];
}
