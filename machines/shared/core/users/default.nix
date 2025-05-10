{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./michael.nix
    ./root.nix
  ];

  environment.systemPackages = with pkgs; [
    gdu # Inspect files and their sizes
    duf # Filesystem usages overview
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [
      ({
        lib,
        inputs,
        osConfig,
        ...
      }: {
        nixpkgs.config.allowUnfree = true;

        colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;
        home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
      })
      inputs.nix-colors.homeManagerModules.default
      ./programs
    ];
  };
}
