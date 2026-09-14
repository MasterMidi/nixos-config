{ ... }:
{
  flake.nixosModules.netbird-client =
    { lib, ... }:
    {
      services.netbird = {
        useRoutingFeatures = lib.mkDefault "client";
        clients.mgrlab = {
          port = 51821;
          interface = "nb-mgrlab";
          hardened = true;
          environment.NB_MANAGEMENT_URL = "https://netbird.mgrlab.dk:443";
        };
      };
    };

  flake.nixosModules.netbird-server =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      domain = "netbird.mgrlab.dk";
      backendAddress = "127.0.0.1:8081";

      serverConfig = (pkgs.formats.yaml { }).generate "netbird-server.yaml" {
        server = {
          listenAddress = backendAddress;
          exposedAddress = "https://${domain}:443";
          stunPorts = [ 3478 ];
          # NetBird only supports selecting the metrics port; the firewall keeps it private.
          metricsPort = 9090;
          healthcheckAddress = "127.0.0.1:9000";
          logLevel = "info";
          logFile = "console";
          dataDir = "/var/lib/netbird";
          authSecret = config.sops.placeholder.NETBIRD_AUTH_SECRET;
          disableAnonymousMetrics = true;

          tls = {
            certFile = "";
            keyFile = "";
            letsencrypt = {
              enabled = false;
              dataDir = "";
              domains = [ ];
              email = "";
              awsRoute53 = false;
            };
          };

          auth = {
            issuer = "https://${domain}/oauth2";
            localAuthDisabled = false;
            signKeyRefreshEnabled = false;
            sessionCookieEncryptionKey = config.sops.placeholder.NETBIRD_IDP_SESSION_COOKIE_ENCRYPTION_KEY;
            dashboardRedirectURIs = [
              "https://${domain}/nb-auth"
              "https://${domain}/nb-silent-auth"
            ];
            cliRedirectURIs = [ "http://localhost:53000/" ];
          };

          store = {
            engine = "sqlite";
            dsn = "";
            file = "/var/lib/netbird/store.db";
            encryptionKey = config.sops.placeholder.NETBIRD_STORE_ENCRYPTION_KEY;
          };
          activityStore = {
            engine = "sqlite";
            dsn = "";
            file = "/var/lib/netbird/events.db";
          };
          authStore = {
            engine = "sqlite3";
            dsn = "";
            file = "/var/lib/netbird/idp.db";
          };
          reverseProxy = {
            trustedHTTPProxies = [ "127.0.0.1/32" ];
            trustedHTTPProxiesCount = 0;
            trustedPeers = [ ];
          };
        };
      };

      httpProxyConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto https;
      '';

      grpcProxyConfig = ''
        grpc_pass grpc://${backendAddress};
        grpc_read_timeout 1d;
        grpc_send_timeout 1d;
        grpc_socket_keepalive on;
        grpc_set_header Host $host;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header X-Forwarded-Host $host;
        grpc_set_header X-Forwarded-Proto https;
      '';
    in
    {
      environment.systemPackages = [ pkgs.netbird-combined ];

      networking.firewall = {
        allowedUDPPorts = [ 3478 ];
        interfaces.podman1.allowedTCPPorts = [ 8080 ];
      };

      services.netbird.server.dashboard = {
        enable = true;
        enableNginx = false;
        inherit domain;
        managementServer = "https://${domain}";
        settings = {
          AUTH_AUTHORITY = "https://${domain}/oauth2";
          AUTH_AUDIENCE = "netbird-dashboard";
          AUTH_CLIENT_ID = "netbird-dashboard";
          AUTH_SUPPORTED_SCOPES = "openid profile email groups";
          AUTH_REDIRECT_URI = "/nb-auth";
          AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
          NETBIRD_TOKEN_SOURCE = "accessToken";
          USE_AUTH0 = false;
        };
      };

      services.nginx = {
        enable = true;
        virtualHosts.${domain} = {
          default = true;
          root = config.services.netbird.server.dashboard.finalDrv;
          extraConfig = ''
            http2 on;
          '';
          listen = [
            {
              addr = "0.0.0.0";
              port = 8080;
            }
          ];

          locations = {
            "/".tryFiles = "$uri $uri.html $uri/ =404";
            "= /nb-auth".tryFiles = "/index.html =404";
            "= /nb-silent-auth".tryFiles = "/index.html =404";

            "/api" = {
              proxyPass = "http://${backendAddress}";
              extraConfig = httpProxyConfig;
            };
            "/oauth2" = {
              proxyPass = "http://${backendAddress}";
              extraConfig = httpProxyConfig;
            };
            "/relay" = {
              proxyPass = "http://${backendAddress}";
              proxyWebsockets = true;
              extraConfig = httpProxyConfig + ''
                proxy_read_timeout 1d;
                proxy_send_timeout 1d;
              '';
            };
            "/ws-proxy/" = {
              proxyPass = "http://${backendAddress}";
              proxyWebsockets = true;
              extraConfig = httpProxyConfig + ''
                proxy_read_timeout 1d;
                proxy_send_timeout 1d;
              '';
            };
            "/signalexchange.SignalExchange/".extraConfig = grpcProxyConfig;
            "/management.ManagementService/".extraConfig = grpcProxyConfig;
          };
        };
      };

      sops.templates.NETBIRD_SERVER_CONFIG = {
        file = serverConfig;
        owner = "netbird-server";
        group = "netbird-server";
        mode = "0400";
        restartUnits = [ "netbird-server.service" ];
      };

      users.groups.netbird-server = { };
      users.users.netbird-server = {
        isSystemUser = true;
        group = "netbird-server";
        home = "/var/lib/netbird";
      };

      systemd.services.netbird-server = {
        description = "NetBird combined server";
        documentation = [ "https://docs.netbird.io/selfhosted/selfhosted-quickstart" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.netbird-combined} --config ${config.sops.templates.NETBIRD_SERVER_CONFIG.path}";
          User = "netbird-server";
          Group = "netbird-server";
          StateDirectory = "netbird";
          StateDirectoryMode = "0700";
          WorkingDirectory = "/var/lib/netbird";
          Restart = "on-failure";
          RestartSec = "5s";
          UMask = "0077";

          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectKernelLogs = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          ProtectClock = true;
          ProtectHostname = true;
          NoNewPrivileges = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RestrictNamespaces = true;
          SystemCallArchitectures = "native";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          CapabilityBoundingSet = "";
        };
      };
    };
}
