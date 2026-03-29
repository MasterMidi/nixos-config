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
        flags = {
          deviceDiscoveryStrategy = "nvml";
          deviceListStrategy = "cdi-cdi";
          cdiAnnotationPrefix = "cdi.k8s.io/";
          # makes the runtime give an index, as they are specified in the /var/run/cdi/nvidia-container-toolkit.json. Alternatively, Update the nvidia-container-toolkit systemd service, to add the parameter: --device-name-strategy=uuid and set this value to uuid as well. This would be preffered, but this solution works for now. https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file#setting-other-helm-chart-values
          plugin.deviceIDStrategy = "index";
        };
        sharing.timeSlicing = {
          renameByDefault = false;
          resources = [
            {
              name = "nvidia.com/gpu";
              replicas = 6;
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
                image = "nvcr.io/nvidia/k8s-device-plugin:v0.19.0";
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
                  cdi.mountPath = "/var/run/cdi";
                };
              };
            };
            volumes = {
              _namedlist = true;
              device-plugin.hostPath.path = "/var/lib/kubelet/device-plugins";
              config.configMap.name = "nvidia-plugin-configs";
              cdi.hostPath.path = "/var/run/cdi";
            };
          };
        };
      };
    };
  };
}
