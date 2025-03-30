{
  pkgs,
  config,
  lib,
  ...
}: let
  traefikConfig = (pkgs.formats.yaml {}).generate "traefik_config.yml" {
    api = {
      insecure = true;
      dashboard = true;
    };

    providers = {
      http = {
        endpoint = "http://pangolin:3001/api/v1/traefik-config";
        pollInterval = "5s";
      };
      file = {
        filename = "/etc/traefik/dynamic_config.yml";
      };
    };

    experimental = {
      plugins = {
        badger = {
          moduleName = "github.com/fosrl/badger";
          version = "v1.0.0-beta.3";
        };
      };
    };

    log = {
      level = "INFO";
      format = "common";
    };

    certificatesResolvers = {
      letsencrypt = {
        acme = {
          dnsChallenge = {
            provider = "cloudflare";
          };
          email = "home@michael-graversen.dk"; # REPLACE THIS WITH YOUR EMAIL
          storage = "/letsencrypt/acme.json";
          caServer = "https://acme-v02.api.letsencrypt.org/directory";
        };
      };
    };

    entryPoints = {
      web = {
        address = ":80";
      };
      websecure = {
        address = ":443";
        transport = {
          respondingTimeouts = {
            readTimeout = "30m";
          };
        };
        http = {
          tls = {
            certResolver = "letsencrypt";
          };
        };
      };
    };

    serversTransport = {
      insecureSkipVerify = true;
    };
  };

  traefikDynamicConfig = (pkgs.formats.yaml {}).generate "dynamic_config.yml" {
    http = {
      middlewares = {
        redirect-to-https = {
          redirectScheme = {
            scheme = "https";
          };
        };
      };

      routers = {
        # HTTP to HTTPS redirect router
        main-app-router-redirect = {
          rule = "Host(`tunnel.mgrlab.dk`)"; # REPLACE THIS WITH YOUR DOMAIN
          service = "next-service";
          entryPoints = ["web"];
          middlewares = ["redirect-to-https"];
        };

        # Next.js router (handles everything except API and WebSocket paths)
        next-router = {
          rule = "Host(`tunnel.mgrlab.dk`) && !PathPrefix(`/api/v1`)"; # REPLACE THIS WITH YOUR DOMAIN
          service = "next-service";
          entryPoints = ["websecure"];
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "mgrlab.dk";
                sans = ["*.mgrlab.dk"];
              }
            ];
          };
        };

        # API router (handles /api/v1 paths)
        api-router = {
          rule = "Host(`tunnel.mgrlab.dk`) && PathPrefix(`/api/v1`)"; # REPLACE THIS WITH YOUR DOMAIN
          service = "api-service";
          entryPoints = ["websecure"];
          tls = {
            certResolver = "letsencrypt";
          };
        };

        # WebSocket router
        ws-router = {
          rule = "Host(`tunnel.mgrlab.dk`)"; # REPLACE THIS WITH YOUR DOMAIN
          service = "api-service";
          entryPoints = ["websecure"];
          tls = {
            certResolver = "letsencrypt";
          };
        };
      };

      services = {
        next-service = {
          loadBalancer = {
            servers = [
              {url = "http://pangolin:3002";} # Next.js server
            ];
          };
        };

        api-service = {
          loadBalancer = {
            servers = [
              {url = "http://pangolin:3000";} # API/WebSocket server
            ];
          };
        };
      };
    };
  };
in {
  virtualisation.oci-containers.compose.tunnel = {
    enable = true;
    networks.default = {};
    containers = {
      pangolin = {
        image = "fosrl/pangolin:1.0.0-beta.14";
        networking = {
          networks = ["default"];
          aliases = ["pangolin"];
        };
        volumes = [
          "/containers/pangolin/config:/app/config"
          "${config.sops.templates.PANGOLIN_CONFIG.path}:/app/config/config.yml:ro"
        ];
        healthcheck = {
          cmd = ["CMD" "curl" "-f" "http://localhost:3001/api/v1/"];
          interval = "3s";
          timeout = "3s";
          retries = 5;
        };
      };
      gerbil = {
        image = "fosrl/gerbil:1.0.0-beta.3";
        networking = {
          networks = ["default"];
          aliases = ["gerbil"];
          ports = {
            traefikHttp = {
              host = 80;
              internal = 80;
              protocol = "tcp";
            };
            traefikHttps = {
              host = 443;
              internal = 443;
              protocol = "tcp";
            };
            wireguard = {
              host = 51820;
              internal = 51820;
              protocol = "udp";
            };
          };
        };
        dependsOn = ["pangolin"];
        commands = [
          "--reachableAt=http://gerbil:3003"
          "--generateAndSaveKeyTo=/var/config/key"
          "--remoteConfig=http://pangolin:3001/api/v1/gerbil/get-config"
          "--reportBandwidthTo=http://pangolin:3001/api/v1/gerbil/receive-bandwidth"
        ];
        volumes = [
          "/containers/pangolin/config/:/var/config"
        ];
        capabilities = ["NET_ADMIN" "SYS_MODULE"];
      };
      traefik = {
        image = "traefik:v3.3.3";
        networking = {
          networks = ["container:gerbil"];
        };
        commands = [
          "--configFile=/etc/traefik/traefik_config.yml"
        ];
        volumes = [
          "${traefikConfig}:/etc/traefik/traefik_config.yml:ro"
          "${traefikDynamicConfig}:/etc/traefik/dynamic_config.yml:ro"
          "/containers/pangolin/config/letsencrypt:/letsencrypt"
        ];
        environment = {
          # CLOUDFLARE_DNS_API_TOKEN = "T0mPP0farwApQcWV0ijHlTI5Olo8Up2M42aJCBT2";
          CF_API_KEY = "35c72073040b7ff45c4beee2fa30decc5f336";
          CF_API_EMAIL = "home@michael-graversen.dk";
        };
      };
    };
  };

  sops.templates.PANGOLIN_CONFIG = {
    restartUnits = [config.virtualisation.oci-containers.compose.tunnel.containers.pangolin.unitName];
    content = lib.generators.toYAML {} {
      app = {
        dashboard_url = "https://tunnel.mgrlab.dk";
        base_domain = "mgrlab.dk";
        log_level = "info";
        save_logs = false;
      };

      server = {
        external_port = 3000;
        internal_port = 3001;
        next_port = 3002;
        internal_hostname = "pangolin";
        session_cookie_name = "p_session_token";
        resource_access_token_param = "p_token";
        resource_session_request_param = "p_session_request";
      };

      traefik = {
        cert_resolver = "letsencrypt";
        http_entrypoint = "web";
        https_entrypoint = "websecure";
        prefer_wildcard_cert = true;
      };

      gerbil = {
        start_port = 51820;
        base_endpoint = "tunnel.mgrlab.dk";
        use_subdomain = false;
        block_size = 24;
        site_block_size = 30;
        subnet_group = "138.199.154.0/24";
      };

      rate_limits = {
        global = {
          window_minutes = 1;
          max_requests = 100;
        };
      };

      users = {
        server_admin = {
          email = "home@michael-graversen.dk";
          password = config.sops.placeholder.PANGOLING_ADMIN_PASSWORD;
        };
      };

      flags = {
        require_email_verification = true;
        disable_signup_without_invite = true;
        disable_user_create_org = true;
        allow_raw_resources = true;
        allow_base_domain_resources = true;
      };
    };
  };
}
