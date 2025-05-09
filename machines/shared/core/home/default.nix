{inputs, ...}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [
      inputs.nix-colors.homeManagerModules.default
      ./programs
      ./shell.nix
    ];
    users.root.imports = [./root.nix];
  };
}
