{ self, ... }:
{
  flake.homeModules.k8s-cluster-administration =
    { pkgs, ... }:
    {
      imports = [ self.homeModules.kubectl ];

      home.packages = with pkgs; [
        k9s
      ];

      programs.kubectl = {
        enable = true;
        settings = {
          apiVersion = "v1";
          kind = "Config";
          clusters = [
            {
              cluster = {
                certificate-authority-data = "";
                server = "https://andromeda:6443";
              };
              name = "default";
            }
          ];
          contexts = [
            {
              context = {
                cluster = "default";
                user = "default";
              };
              name = "default";
            }
          ];
          users = [
            {
              name = "default";
              user = {
                client-certificate-data = "";
                client-key-data = "";
              };
            }
          ];
        };
      };
    };
}
