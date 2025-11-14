{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  environment.systemPackages = with pkgs; [
    gdu # Inspect files and their sizes
    duf # Filesystem usages overview
    magic-wormhole-rs # send files between systems
    trash-cli # manage trash files
    lazygit # TUI git client
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    sharedModules = [
      inputs.nix-colors.homeManagerModules.default

      (
        { osConfig, ... }:
        {
          nixpkgs.config.allowUnfree = true;

          colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;
          home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
        }
      )

      ./programs
    ];
  };
}
