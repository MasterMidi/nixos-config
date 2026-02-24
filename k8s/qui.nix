{ ... }:
let
  app = "qui";
in
{
  kubernetes.resources.media-stack = {
    Service.${app} = {
      spec = {
        ports = {
          _namedlist = true;
          http = {
            port = 7476;
            targetPort = 7476;
          };
        };
        selector = { inherit app; };
      };
    };
    Deployment.${app} = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = { inherit app; };
        template = {
          metadata.labels = { inherit app; };
          spec = {
            containers = {
              _namedlist = true;
              qui = {
                image = "ghcr.io/autobrr/qui:v1.13";
                ports = {
                  _namedlist = true;
                  http.containerPort = 7476;
                };
                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/config";
                  storage.mountPath = "/storage";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.hostPath = {
                path = "/mnt/ssd/appdata/qui";
                type = "DirectoryOrCreate";
              };
              storage.hostPath = {
                path = "/mnt/hdd";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
