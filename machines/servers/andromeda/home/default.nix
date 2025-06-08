{inputs, ...}: {
  users.users.michael.extraGroups = ["networkmanager" "wheel" "dialout"];

  home-manager.users.michael.imports = [
    ./home.nix
  ];
}
