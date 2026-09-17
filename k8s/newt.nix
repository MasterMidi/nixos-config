{ lib, ... }:
{
  kubernetes.resources.default = {
    Secret.newt-secret = {
      stringData = {
        NEWT_SECRET = "{{ secrets.newt }}";
      };
    };
    Deployment.newt = {
      spec = {
        replicas = 1;
        selector.matchLabels.app = "newt";
        template = {
          metadata.labels.app = "newt";
          spec = {
            containers = lib.mkNamedList {
              newt = {
                name = "newt";
                image = "fosrl/newt:1.17.0";
                env = lib.mkNamedList {
                  PANGOLIN_ENDPOINT.value = "https://tunnel.mgrlab.dk";
                  NEWT_ID.value = "npjvjb7lh3mgr3n";
                  NEWT_SECRET.valueFrom.secretKeyRef = {
                    name = "newt-secret";
                    key = "NEWT_SECRET";
                  };
                };
                securityContext.capabilities.add = [ "NET_ADMIN" ];
              };
            };
          };
        };
      };
    };
  };
}
