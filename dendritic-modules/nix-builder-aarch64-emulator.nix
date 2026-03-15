{ self, ... }:
{
  flake.nixosModules.builder =
    { ... }:
    {
      imports = [ self.nixosModules.nix-builder ];

      # Enable QEMU emulation for aarch64-linux.
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
}
