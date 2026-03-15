{ inputs, self, ... }:
{
  flake.nixosConfigurations.hyperionV2 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.hyperionModule
    ];
  };

  flake.nixosModules.hyperionModule =
    { pkgs, ... }:
    {

    };
}
