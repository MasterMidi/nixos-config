{ self, ... }:
{
  flake.nixosModules.k3s-node-agent =
    { ... }:
    {
      imports = [ self.nixosModules.k3s-node ];

      services.k3s.role = "agent";
    };
}
