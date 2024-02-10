{
  description = "Build image";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  outputs = { self, nixpkgs }: rec {
    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
          # ... extra configs as above
          system.stateVersion = "23.11";
        }
      ];
    };
    images.rpi3 = nixosConfigurations.rpi3.config.system.build.sdImage;
  };
}
