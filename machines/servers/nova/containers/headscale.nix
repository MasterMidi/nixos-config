{ pkgs, config, ... }:
{
  virtualisation.oci-containers.compose.tunnel.containers = {
    headscale = {
      image = "docker.io/headscale/headscale:v0.26.1";
      networking = {
        networks = [ "default" ];
        aliases = [ "headscale" ];
      };
      commands = [ "serve" ];
      volumes = [
        "/mnt/ssd/services/headscale/config:/etc/headscale"
        "/mnt/ssd/services/headscale/lib:/var/lib/headscale"
        "/mnt/ssd/services/headscale/run:/var/run/headscale"
      ];
    };
  };

  sops.templates.HEADSCALE_CONFIG = {
    owner = config.users.users.michael.name;
    group = config.users.groups.users.name;
    restartUnits = [
      config.virtualisation.oci-containers.compose.mediaserver.containers.headscale.unitName
    ];
    file = (pkgs.formats.yaml { }).generate "config.yml" {
      # -----------------------------------------------------------------
      # Core Server Configuration
      # -----------------------------------------------------------------
      server_url = "https://vpn.mgrlab.dk";

      # Address to listen on. For production, 0.0.0.0:8080 is common if headscale
      # is directly exposed. If it's behind a reverse proxy like nginx,
      # "127.0.0.1:8080" is recommended.
      listen_addr = "127.0.0.1:8080";
      metrics_listen_addr = "127.0.0.1:9090";
      grpc_listen_addr = "127.0.0.1:50443";
      grpc_allow_insecure = false;

      noise.private_key_path = "/var/lib/headscale/noise_private.key";

      # -----------------------------------------------------------------
      # IP & Network Configuration
      # -----------------------------------------------------------------
      ip_prefixes = {
        v4 = "100.64.0.0/10";
        v6 = "fd7a:115c:a1e0::/48";
        allocation = "random";
      };

      # -----------------------------------------------------------------
      # DERP (Relay Server) Configuration
      # -----------------------------------------------------------------
      derp = {
        # Use Tailscale's public DERP servers.
        urls = [ "https://controlplane.tailscale.com/derpmap/default" ];
        auto_update_enabled = true;
        update_frequency = "24h";

        # This configuration does not enable the embedded DERP server.
        # Running your own DERP server is an advanced topic.
        server = {
          enabled = false;
        };
      };

      # -----------------------------------------------------------------
      # DNS Configuration (MagicDNS)
      # -----------------------------------------------------------------
      dns = {
        magic_dns = true;

        # IMPORTANT: This MUST be a different domain than your server_url.
        # A common convention is to use a subdomain, like "ts.mgrlab.dk".
        base_domain = "ts.mgrlab.dk";

        override_local_dns = false;
        nameservers.global = [
          "1.1.1.1" # Cloudflare
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };

      database = {
        type = "sqlite";
        debug = false;
        gorm = {
          prepare_stmt = true;
          parameterized_queries = true;
          skip_err_record_not_found = true;
          slow_threshold = 1000;
        };
        sqlite = {
          path = "/var/lib/headscale/db.sqlite";
          write_ahead_log = true;
          wal_autocheckpoint = 1000;
        };
      };

      log = {
        format = "text";
        level = "info";
      };

      # -----------------------------------------------------------------
      # ACL Policy Configuration
      # -----------------------------------------------------------------
      policy = {
        mode = "database";
        # path = "/var/lib/headscale/acl.hujson";
      };

      # -----------------------------------------------------------------
      # Open ID Connect (OIDC) - Merged from your config
      # -----------------------------------------------------------------
      oidc = {
        # It's good practice to ensure headscale doesn't start if OIDC is misconfigured.
        only_start_if_oidc_is_available = true;

        issuer = "https://oidc.mgrlab.dk";
        client_id = "b27dae02-d4d6-4e08-b4e6-2da567806df9";

        # For better security, consider managing this secret with something like
        # agenix, sops-nix, or another secrets management tool.
        client_secret = "zAmHFUjpxeddhC9mfdPTs5b0XNPhQjpM";

        scope = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        allowed_groups = [ "vpn" ];
        pkce = {
          enabled = true;
          method = "S256";
        };

        # How long a node key is valid before it needs to be re-authenticated.
        # expiry = "180d";
      };

      # -----------------------------------------------------------------
      # Miscellaneous Settings
      # -----------------------------------------------------------------
      logtail.enabled = false; # Avoid sending logs to Tailscale Inc.
      randomize_client_port = false;
      ephemeral_node_inactivity_timeout = "30m";
    };
  };
}
