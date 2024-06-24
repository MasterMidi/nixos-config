{...}: {
  imports = [
    ./avahi.nix
    ./nix.nix
    ./packages.nix
    ./sops.nix
		./system.nix
    ./upgrade-diff.nix
  ];
}
