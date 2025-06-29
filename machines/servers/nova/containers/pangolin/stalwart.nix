{ pkgs, config, ... }:
{
  virtualisation.oci-containers.compose.tunnel.containers = {
    traefik-certs-dumper = {
      image = "ghcr.io/kereis/traefik-certs-dumper:latest";
      dependsOn = [ "traefik" ]; # Assumes traefik is in another compose group
      volumes = [
        "/containers/pangolin/config/letsencrypt:/traefik:ro" # Note: podman prepends the compose group name
        "/containers/pangolin/certs:/output"
      ];
      # Make sure it's on the same network to access volumes
      networking.networks = [ "default" ]; # Adjust if your proxy network has a different name
    };

    # The Stalwart mail server itself
    stalwart = {
      image = "stalwartlabs/stalwart:latest";
      # user = "1000";
      # group = "1000";
      dependsOn = [ "traefik-certs-dumper" ];
      volumes = [
        # "${config.sops.secrets.stalwart_config.path}:/etc/stalwart/stalwart.toml:ro"
        "${config.sops.templates.STALWART_CONFIG.path}:/opt/stalwart/etc/config.toml"
        "/containers/stalwart/data:/opt/stalwart"
        "/containers/pangolin/certs:/certs:ro" # Mount the certs read-only
      ];
      networking = {
        networks = [ "default" ]; # Use the shared mail network
        aliases = [ "stalwart" ];
        # ips = [ "172.19.0.5" ]; # Assign a static IP as in the docs
      };
    };
  };

  sops.templates.STALWART_CONFIG = {
    restartUnits = [ config.virtualisation.oci-containers.compose.tunnel.containers.stalwart.unitName ];
    mode = "0600";
    file = (pkgs.formats.toml { }).generate "stalwart-mail.toml" {
      server = {
        hostname = "mail.mgrlab.dk";
        listener = {
          smtp = {
            bind = [ "[::]:25" ];
            protocol = "smtp";
            proxy.trusted-networks = [
              # localhost
              "127.0.0.0/8"
              "::1"

              # podman network
              "10.0.0.0/8"
            ];
          };
          submission = {
            bind = [ "[::]:587" ];
            protocol = "smtp";
            proxy.trusted-networks = [
              # localhost
              "127.0.0.0/8"
              "::1"

              # podman network
              "10.0.0.0/8"
            ];
          };
          submissions = {
            bind = [ "[::]:465" ];
            protocol = "smtp";
            tls.implicit = true;
            proxy.trusted-networks = [
              # localhost
              "127.0.0.0/8"
              "::1"

              # podman network
              "10.0.0.0/8"
            ];
          };
          # imap = {
          #   bind = [ "[::]:143" ];
          #   protocol = "imap";
          # };
          imaptls = {
            bind = [ "[::]:993" ];
            protocol = "imap";
            tls.implicit = true;
            proxy.trusted-networks = [
              # localhost
              "127.0.0.0/8"
              "::1"

              # podman network
              "10.0.0.0/8"
            ];
          };
          # sieve = {
          #   bind = [ "[::]:4190" ];
          #   protocol = "managesieve";
          # };
          http = {
            bind = [ "[::]:8080" ];
            protocol = "http";
          };
          https = {
            bind = [ "[::]:443" ];
            protocol = "http";
            tls.implicit = true;
          };
        };
        http = {
          hsts = true;
          permissive-cors = false;
          url = "protocol + '://' + config_get('server.hostname') + ':' + local_port";
          use-x-forwarded = true;
        };
        allowed-ip = {
          "10.89.0.98" = "";
        };
      };

      certificate.default = {
        default = true;
        cert = "%{file:/certs/mgrlab.dk/cert.pem}%";
        private-key = "%{file:/certs/mgrlab.dk/key.pem}%";
      };

      session.auth.mechanisms = [
        "PLAIN"
        "LOGIN"
        # "OAUTHBEARER"
        # "XOAUTH2"
      ];

      authentication.fallback-admin = {
        user = "admin";
        secret = config.sops.placeholder.STALWART_ADMIN_PASSWORD;
      };

      storage = {
        data = "rocksdb";
        fts = "rocksdb";
        blob = "rocksdb";
        lookup = "rocksdb";
        directory = "internal";
      };

      store.rocksdb = {
        type = "rocksdb";
        path = "/opt/stalwart/data";
        compression = "lz4";
      };

      directory.internal = {
        type = "internal";
        store = "rocksdb";
      };

      # directory.oidc-userinfo = {
      #   type = "oidc";
      #   timeout = "1s";
      #   endpoint.url = "https://oidc.mgrlab.dk/api/oidc/userinfo";
      #   endpoint.method = "userinfo";
      #   fields.email = "email";
      #   fields.username = "preferred_username";
      #   fields.full-name = "name";
      # };

      tracer = {
        console = {
          type = "console";
          level = "info";
          ansi = true;
          enable = true;
        };
      };
    };
  };
}
