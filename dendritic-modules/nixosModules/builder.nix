{ ... }:
{
  flake.nixosModules.builder =
    { ... }:
    {
      # 1. Enable QEMU emulation for aarch64-linux.
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      # 2. Create a dedicated user for incoming build requests
      users.users.nix-builder = {
        isNormalUser = true;
        description = "Dedicated user for Nix remote builds";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/wwcgUh2vV59HySfZKgRDxI69eHHIrOAEVyWZNxvfY nix-remote-builder"
        ];
      };

      # 3. Ensure the Nix daemon trusts this user.
      # Without this, the builder cannot substitute outputs from its own binary cache.
      nix.settings.trusted-users = [ "nix-builder" ];

      # 4. Ensure the SSH daemon is running and allows the connection
      services.openssh.enable = true;
    };
}
