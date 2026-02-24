{ ... }:
let
  daemonSet = "nvidia-device-plugin-daemonset";
  confMap = "nvidia-plugin-configs";
in
{
  kubernetes.resources.kube-system = {
    RuntimeClass.nvidia = {
      metadata.labels."app.kubernetes.io/component" = "gpu-operator";
      handler = "nvidia";
    };
    ConfigMap.${confMap} = {
      data."config.yaml" = builtins.toJSON {
        version = "v1";
        flags.deviceDiscoveryStrategy = "nvml";
        sharing.timeSlicing = {
          renameByDefault = false;
          resources = [
            {
              name = "nvidia.com/gpu";
              replicas = 10;
            }
          ];
        };
      };
    };
    DaemonSet.${daemonSet} = {
      spec = {
        selector.matchLabels.name = "nvidia-device-plugin-ds";
        updateStrategy.type = "RollingUpdate";
        template = {
          metadata.labels.name = "nvidia-device-plugin-ds";
          spec = {
            runtimeClassName = "nvidia";
            tolerations = [
              {
                key = "nvidia.com/gpu";
                operator = "Exists";
                effect = "NoSchedule";
              }
            ];
            containers = {
              _namedlist = true;
              ${daemonSet} = {
                image = "nvcr.io/nvidia/k8s-device-plugin:v0.18.0";
                args = [
                  "--config-file"
                  "/etc/nvidia-device-plugin/config.yaml"
                ];
                env = {
                  _namedlist = true;
                  NVIDIA_VISIBLE_DEVICES.value = "all";
                  NVIDIA_DRIVER_CAPABILITIES.value = "all";
                };
                securityContext = {
                  allowPrivilegeEscalation = false;
                  capabilities.drop = [ "ALL" ];
                };
                volumeMounts = {
                  _namedlist = true;
                  device-plugin.mountPath = "/var/lib/kubelet/device-plugins";
                  config.mountPath = "/etc/nvidia-device-plugin";
                };
              };
            };
            volumes = {
              _namedlist = true;
              device-plugin.hostPath.path = "/var/lib/kubelet/device-plugins";
              config.configMap.name = "nvidia-plugin-configs";
            };
          };
        };
      };
    };
  };
}
