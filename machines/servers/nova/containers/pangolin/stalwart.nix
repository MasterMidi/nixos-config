{ pkgs, config, ... }:
let
  config = (pkgs.formats.toml { }).generate "stalwart-mail.toml" {
    server = {
      hostname = "mail.mgrlab.dk";
      listener = {
        smtp = {
          bind = [ "[::]:25" ];
          protocol = "smtp";
        };
        submission = {
          bind = [ "[::]:587" ];
          protocol = "smtp";
        };
        submissions = {
          bind = [ "[::]:465" ];
          protocol = "smtp";
          tls.implicit = true;
        };
        # imap = {
        #   bind = [ "[::]:143" ];
        #   protocol = "imap";
        # };
        imaptls = {
          bind = [ "[::]:993" ];
          protocol = "imap";
          tls.implicit = true;
        };
        sieve = {
          bind = [ "[::]:4190" ];
          protocol = "managesieve";
        };
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
    };

    certificate.default = {
      default = true;
      cert = "%{file:/certs/mgrlab.dk/cert.pem}%";
      private-key = "%{file:/certs/mgrlab.dk/key.pem}%";
    };

    # session.auth = {
    #   mechanisms = ["PLAIN" "LOGIN" "OAUTHBEARER"];
    # };

    authentication.fallback-admin = {
      user = "admin";
      # secret = "%{file:${config.sops.secrets.STALWART_ADMIN_PASSWORD.path}}%";
      secret = "$6$6Yg./qvOZhF4zaH6$xPjHXko9i9Mu2lSEd3ZS5CylRpbXiHCbD4u1Q2GzS6OZO058UXxil0g6jaBUJWt7ha0CRFkJrKpPa17iRdFu31";
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

    tracer = {
      console = {
        type = "console";
        level = "info";
        ansi = true;
        enable = true;
      };
    };
  };
in
{
  virtualisation.oci-containers.compose.tunnel.containers = {
    traefik-certs-dumper = {
      image = "ghcr.io/kereis/traefik-certs-dumper:latest";
      dependsOn = [ "traefik" ]; # Assumes traefik is in another compose group
      volumes = [
        "/containers/traefik/acme:/traefik:ro" # Note: podman prepends the compose group name
        "/containers/traefik/certs:/output"
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
        "${config}:/opt/stalwart/etc/config.toml"
        "/containers/stalwart/data:/opt/stalwart"
        "/containers/traefik/certs:/certs:ro" # Mount the certs read-only
      ];
      networking = {
        networks = [ "default" ]; # Use the shared mail network
        aliases = [ "stalwart" ];
        # ips = [ "172.19.0.5" ]; # Assign a static IP as in the docs
      };
    };
  };
}
