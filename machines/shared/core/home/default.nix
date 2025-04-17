{inputs, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [
      inputs.nix-colors.homeManagerModules.default
    ];
    users.root.imports = [
      ./root.nix
      ./shell.nix
      ./starship.nix
    ];
  };
}
