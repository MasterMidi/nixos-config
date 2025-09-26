{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./michael.nix
    ./root.nix
  ];

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
      ./base.nix
      ./programs
    ];
  };
}
