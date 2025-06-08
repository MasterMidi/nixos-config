{inputs, ...}: {
  # imports = [inputs.home-manager.nixosModules.home-manager];
  users.users.michael.extraGroups = ["networkmanager" "wheel" "dialout"];

  home-manager.users.michael.imports = [
    ./home.nix
    ./hyprland.nix
  ];
}
