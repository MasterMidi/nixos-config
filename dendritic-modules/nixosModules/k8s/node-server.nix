{ self, ... }:
{
  flake.nixosModules.k3s-node-server =
    { ... }:
    {
      imports = [ self.nixosModules.k3s-node ];

      services.k3s.role = "server";
    };
}
