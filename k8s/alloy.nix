{ pkgs, ... }:
{
  helm.releases.alloy = {
    namespace = "alloy";
    chart = pkgs.fetchHelm {
      repo = "https://grafana.github.io/helm-charts";
      chart = "alloy";
      version = "1.10.1";
      sha256 = "sha256-RRljllJwqnOPRn9uUkqCH5zUQqshWRgkI7Q+/2UzN7c=";
    };

    values = {
      alloy.configMap.content = builtins.readFile ./alloy-config.alloy;

      controller = {
        type = "deployment";
        replicas = 1;
      };

      crds.create = false;

      rbac = {
        namespaces = [ "media-stack" ];
        rules = [
          {
            apiGroups = [ "" ];
            resources = [
              "pods"
              "pods/log"
            ];
            verbs = [
              "get"
              "list"
              "watch"
            ];
          }
        ];
      };
    };
  };
}
