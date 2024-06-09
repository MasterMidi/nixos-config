{...}: {
  imports = [
    ./avahi.nix
    ./nix.nix
    ./packages.nix
    ./sops.nix
    ./upgrade-diff.nix
  ];
}
