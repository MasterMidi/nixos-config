{...}: {
  imports = [
    ./homarr.nix
    ./mealie.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
