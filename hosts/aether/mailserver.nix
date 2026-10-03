{ config, pkgs, ... }:
{
  services.stalwart = {
    enable = true;
    stateVersion = "26.05";
    settings = {
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
          imaptls = {
            bind = [ "[::]:993" ];
            protocol = "imap";
            tls.implicit = true;
          };
          http = {
            bind = [ "127.0.0.1:4848" ];
            protocol = "http";
          };
        };
      };

      http = {
        use-x-forwarded = true;
        url = "'https://mail.mgrlab.dk'";
      };

      certificate.default = {
        default = true;
        cert = "%{file:/var/lib/acme/mail.mgrlab.dk/fullchain.pem}%";
        private-key = "%{file:/var/lib/acme/mail.mgrlab.dk/key.pem}%";
      };

      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/run/credentials/stalwart.service/user_admin_password}%";
      };

      # Publish IPv6 forward DNS and SPF before using the Hetzner IPv6 source.
      queue.connection.default.source-ips = [ "138.199.154.23" ];
    };
    credentials.user_admin_password = config.sops.secrets.STALWART_ADMIN_PASSWORD.path;
  };

  # SMTP and mail-client protocols need end-to-end TLS; Traefik handles only HTTP.
  networking.firewall.allowedTCPPorts = [
    25
    465
    587
    993
  ];

  security.acme = {
    acceptTerms = true;
    certs."mail.mgrlab.dk" = {
      email = "home@michael-graversen.dk";
      dnsProvider = "cloudflare";
      environmentFile = pkgs.writeText "stalwart-acme-cloudflare.env" ''
        CF_API_EMAIL=home@michael-graversen.dk
      '';
      credentialFiles.CF_API_KEY_FILE = config.sops.secrets.CLOUDFLARE_GLOBAL_API_KEY.path;
      group = config.services.stalwart.group;
      reloadServices = [ "stalwart.service" ];
    };
  };

  systemd.services.stalwart = {
    requires = [ "acme-mail.mgrlab.dk.service" ];
    after = [ "acme-mail.mgrlab.dk.service" ];
  };

  # The Pangolin wildcard router also matches mail.mgrlab.dk; use a more
  # specific router for the Stalwart management UI and JMAP endpoint.
  services.traefik.dynamicConfigOptions.http = {
    routers.stalwart = {
      rule = "Host(`mail.mgrlab.dk`)";
      entryPoints = [ "websecure" ];
      priority = 1000;
      service = "stalwart";
      tls.certResolver = "letsencrypt";
    };
    services.stalwart.loadBalancer.servers = [ { url = "http://127.0.0.1:4848"; } ];
  };
}
