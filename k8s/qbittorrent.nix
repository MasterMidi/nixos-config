{ lib, ... }:
let
  app = "qbittorrent";
in
{
  kubernetes.resources.media-stack = rec {
    PersistentVolumeClaim."${app}-config" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn";
        resources.requests.storage = "500Mi";
      };
    };

    Service.${app} = {
      spec = {
        ports = lib.mkNamedList {
          webui = {
            port = Deployment.${app}.spec.template.spec.containers.${app}.ports.webui.containerPort;
            targetPort = Deployment.${app}.spec.template.spec.containers.${app}.ports.webui.containerPort;
          };
          torrent-tcp = {
            port = Deployment.${app}.spec.template.spec.containers.${app}.ports.torrent-tcp.containerPort;
            targetPort = Deployment.${app}.spec.template.spec.containers.${app}.ports.torrent-tcp.containerPort;
            protocol = "TCP";
          };
          torrent-udp = {
            port = Deployment.${app}.spec.template.spec.containers.${app}.ports.torrent-udp.containerPort;
            targetPort = Deployment.${app}.spec.template.spec.containers.${app}.ports.torrent-udp.containerPort;
            protocol = "UDP";
          };
          privoxy-tcp = {
            port = Deployment.${app}.spec.template.spec.containers.${app}.ports.privoxy-tcp.containerPort;
            targetPort = Deployment.${app}.spec.template.spec.containers.${app}.ports.privoxy-tcp.containerPort;
            protocol = "TCP";
          };
          privoxy-udp = {
            port = Deployment.${app}.spec.template.spec.containers.${app}.ports.privoxy-udp.containerPort;
            targetPort = Deployment.${app}.spec.template.spec.containers.${app}.ports.privoxy-udp.containerPort;
            protocol = "UDP";
          };
        };
        selector = { inherit app; };
      };
    };
    Deployment.${app} = {
      spec = {
        replicas = 1;
        selector.matchLabels = { inherit app; };
        template = {
          metadata.labels = { inherit app; };
          spec = {
            securityContext.sysctls = lib.mkNamedList {
              "net.ipv4.conf.all.src_valid_mark".value = "1";
            };
            resources.requests.cpu = "100m";
            containers = lib.mkNamedList {
              ${app} = {
                image = "ghcr.io/hotio/qbittorrent:release-v5";
                securityContext.capabilities.add = [ "NET_ADMIN" ];
                env = lib.mkNamedList {
                  PUID.value = "1000";
                  PGID.value = "100";
                  TZ.value = "Europe/Copenhagen";
                  UMASK.value = "002";
                  WEBUI_PORTS.value = "9060/tcp,9060/udp";
                  PRIVOXY_ENABLED.value = "true";
                  UNBOUND_ENABLED.value = "false";

                  # VPN configuration
                  VPN_ENABLED.value = "true";
                  VPN_CONF.value = "wg0";
                  VPN_PROVIDER.value = "generic";
                  VPN_LAN_NETWORK.value = "192.168.1.0/24";
                  VPN_LAN_LEAK_ENABLED.value = "false";
                  # VPN_EXPOSE_PORTS_ON_LAN.value = "8118/tcp,8118/udp";
                  VPN_KEEP_LOCAL_DNS.value = "true";
                  VPN_FIREWALL_TYPE.value = "auto";
                  VPN_HEALTHCHECK_ENABLED.value = "false";

                  # AirVPN manually allocated forwarded port
                  VPN_AUTO_PORT_FORWARD.value = "37461";

                  # Expose the qBittorrent listening port through wg0
                  VPN_PORT_REDIRECTS.value = "37461/tcp,37461/udp";
                };
                ports = lib.mkNamedList {
                  webui.containerPort = 9060;
                  torrent-tcp = {
                    containerPort = 37461;
                    protocol = "TCP";
                  };
                  torrent-udp = {
                    containerPort = 37461;
                    protocol = "UDP";
                  };
                  privoxy-tcp = {
                    containerPort = 8118;
                    protocol = "TCP";
                  };
                  privoxy-udp = {
                    containerPort = 8118;
                    protocol = "UDP";
                  };
                };
                volumeMounts = lib.mkNamedList {
                  config.mountPath = "/config";
                  storage.mountPath = "/storage";
                  wg-conf.mountPath = "/config/wireguard/wg0.conf";
                  tun-device.mountPath = "/dev/net/tun";
                };
              };
            };
            volumes = lib.mkNamedList {
              config.persistentVolumeClaim.claimName = "${app}-config";
              storage.hostPath = {
                path = "/mnt/hdd";
                type = "Directory";
              };
              wg-conf.hostPath = {
                path = "/var/run/secrets/rendered/WIREGUARD_AIRVPN_CONF";
                type = "File";
              };
              tun-device.hostPath = {
                path = "/dev/net/tun";
                type = "CharDevice";
              };
            };
          };
        };
      };
    };
  };
}
