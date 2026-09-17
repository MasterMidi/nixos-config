{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.pangolin = {
    enable = true;
    openFirewall = true;
    baseDomain = "mgrlab.dk";
    dashboardDomain = "tunnel.mgrlab.dk";
    dnsProvider = "cloudflare";
    letsEncryptEmail = "home@michael-graversen.dk";
    environmentFile = config.sops.templates.PANGOLIN_ENV.path;

    settings = {
      app = {
        log_failed_attempts = true;
        log_level = "debug";
        save_logs = false;
      };

      domains.domain1 = {
        cert_resolver = "letsencrypt";
        prefer_wildcard_cert = true;
      };

      server = {
        session_cookie_name = "p_session_token";
        resource_access_token_param = "p_token";
        resource_session_request_param = "p_session_request";
      };

      traefik = {
        http_entrypoint = "web";
        https_entrypoint = "websecure";
      };

      gerbil = {
        start_port = 51820;
        use_subdomain = false;
        block_size = 24;
        site_block_size = 30;
        subnet_group = "100.89.137.0/20";
      };

      rate_limits.global = {
        window_minutes = 1;
        max_requests = 100;
      };

      flags = {
        require_email_verification = true;
        disable_signup_without_invite = true;
        disable_user_create_org = true;
        allow_raw_resources = true;
      };
    };
  };

  services.traefik = {
    environmentFiles = [ config.sops.templates.TRAEFIK_ENV.path ];
    staticConfigOptions = {
      log = {
        level = "INFO";
        format = "common";
      };
      accessLog.format = "common";
      experimental.plugins.badger.version = lib.mkForce "v1.5.0";
      entryPoints.websecure.http.encodedCharacters = {
        allowEncodedSlash = true;
        allowEncodedQuestionMark = true;
      };
      serversTransport.insecureSkipVerify = true;
      ping.entryPoint = "web";
    };

    dynamicConfigOptions = {
      http = {
        middlewares.badger.plugin.badger.disableForwardAuth = true;
        routers = {
          main-app-router-redirect.middlewares = lib.mkForce [
            "redirect-to-https"
            "badger"
          ];
          next-router = {
            middlewares = [ "badger" ];
            # The module's wildcard domain shape does not match Traefik's schema.
            tls.domains = lib.mkForce [
              {
                main = "mgrlab.dk";
                sans = [ "*.mgrlab.dk" ];
              }
            ];
          };
          api-router.middlewares = [ "badger" ];
          ws-router.middlewares = [ "badger" ];
        };
      };
      tcp.serversTransports = {
        pp-transport-v1.proxyProtocol.version = 1;
        pp-transport-v2.proxyProtocol.version = 2;
      };
    };
  };

  # Keep existing Pangolin resources targeting the old container alias working.
  networking = {
    # hosts."127.0.0.2" = [ "vaultwarden" ];
    firewall.allowedUDPPorts = [ 21820 ];
  };

  sops.templates = {
    PANGOLIN_ENV = {
      owner = "pangolin";
      group = "fossorial";
      mode = "0440";
      restartUnits = [ "pangolin.service" ];
      content = ''
        SERVER_SECRET=${config.sops.placeholder.PANGOLIN_SERVER_SECRET}
      '';
    };

    TRAEFIK_ENV = {
      owner = "traefik";
      group = "fossorial";
      mode = "0440";
      restartUnits = [ "traefik.service" ];
      content = ''
        CF_API_EMAIL=home@michael-graversen.dk
        CF_API_KEY=${config.sops.placeholder.CLOUDFLARE_GLOBAL_API_KEY}
      '';
    };
  };
}
