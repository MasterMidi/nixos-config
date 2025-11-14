{config, ...}: {
  services.stalwart-mail = {
    enable = false;
    openFirewall = true; # sits behind reverse proxy instead
    settings = {
      server = {
        listener = {
          smtp = {
            bind = ["[::]:25"];
            protocol = "smtp";
          };
          submission = {
            bind = ["[::]:587"];
            protocol = "smtp";
          };
          submissions = {
            bind = ["[::]:465"];
            protocol = "smtp";
            tls.implicit = true;
          };
          imap = {
            bind = ["[::]:143"];
            protocol = "imap";
          };
          imaptls = {
            bind = ["[::]:993"];
            protocol = "imap";
            # tls.implicit = true;
          };
          http = {
            bind = ["[::]:4848"];
            protocol = "http";
          };
          https = {
            bind = ["[::]:4949"];
            protocol = "http";
          };
        };
        hostname = "mail.mgrlab.dk";
        # http = {
        #   hsts = true;
        #   permissive-cors = false;
        #   url = "protocol + '://' + config_get('server.hostname') + ':' + local_port";
        #   use-x-forwarded = true;
        # };
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
        secret = "%{file:${config.sops.secrets.STALWART_ADMIN_PASSWORD.path}}%";
      };

      tracer = {
        # journald = {
        #   type = "log";
        #   path = "/opt/stalwart-mail/logs";
        #   prefix = "stalwart-mail.log";
        #   rotate = "daily";
        #   level = "info";
        #   ansi = true;
        #   enable = true;
        # };
      };
    };
    credentials = {user_admin_password = config.sops.secrets.STALWART_ADMIN_PASSWORD.path;};
  };
}
