{ pkgs, ... }:
{
  helm.releases.alloy = {
    namespace = "alloy";
    chart = pkgs.fetchHelm {
      repo = "https://grafana.github.io/helm-charts";
      chart = "alloy";
      version = "1.15.0";
      sha256 = "sha256-efDrZJdDGVGHGkuC5KOE74IHz+/GrUJJU8RZwpY8lgE=";
    };

    values = {
      alloy.configMap.content = builtins.readFile ./alloy-config.alloy;

      controller = {
        type = "daemonset";
      };

      crds.create = false;

      rbac = {
        # namespaces = [ "media-stack" ];
        rules = [
          {
            apiGroups = [ "" ];
            resources = [
              "events"
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
