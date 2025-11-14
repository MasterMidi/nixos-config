# /etc/nixos/penpot.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Pre-declare the directories needed for persistent data.
  # Ensure the user/group running podman has write access.
  systemd.tmpfiles.rules = [
    "d /mnt/ssd/services/penpot/data 0750 root root - -"
    "d /mnt/ssd/services/penpot/assets 0750 root root - -"
  ];

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      # ---------------------------
      # --- PostgreSQL Database ---
      # ---------------------------
      penpot-postgres = {
        networking = {
          networks = [ "default" ];
          aliases = [ "penpot-postgres" ];
        };
        image = "postgres:15";
        environment = {
          POSTGRES_DB = "penpot";
          POSTGRES_USER = "penpot";
          POSTGRES_PASSWORD = "penpot"; # For production, consider using a secret
          POSTGRES_INITDB_ARGS = "--data-checksums";
        };
        volumes = [
          "/mnt/ssd/services/penpot/data:/var/lib/postgresql/data"
        ];
        healthcheck = {
          cmd = [
            "pg_isready"
            "-U"
            "penpot"
          ];
          interval = "10s";
          timeout = "5s";
          retries = 5;
          startPeriod = "5s";
        };
      };

      # ----------------
      # --- Redis    ---
      # ----------------
      penpot-redis = {
        image = "redis:7.2";
        networking = {
          networks = [ "default" ];
          aliases = [ "penpot-redis" ];
        };
        healthcheck = {
          # The nix module expects a list of strings for the command.
          # To run a shell pipeline, we use sh -c.
          cmd = [
            "sh"
            "-c"
            "redis-cli ping | grep PONG"
          ];
          interval = "2s";
          timeout = "3s";
          retries = 5;
          startPeriod = "3s";
        };
      };

      # --------------------
      # --- Penpot Backend ---
      # --------------------
      penpot-backend = {
        image = "penpotapp/backend:latest";
        networking = {
          networks = [ "default" ];
          aliases = [ "penpot-backend" ];
        };
        dependsOn = [
          "penpot-postgres"
          "penpot-redis"
        ];
        environment = {
          # --- General Flags ---
          # enable-smtp: Required for sending invitations.
          # enable-prepl-server: For administrative CLI tasks.
          # enable-login-with-oidc: Enables the OIDC login button.
          # enable-oidc-registration: Allows new users to register via OIDC.
          PENPOT_FLAGS =
            [
              "enable-smtp"
              "enable-log-emails"
              "enable-prepl-server"
              "enable-login-with-oidc"
              "enable-oidc-registration"
            ]
            |> builtins.concatStringsSep " ";

          # Max body size (30MiB); Used for plain requests, should never be
          # greater than multi-part size
          PENPOT_HTTP_SERVER_MAX_BODY_SIZE = "31457280";
          # Max multipart body size (350MiB)
          PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE = "367001600";

          # --- Public URI ---
          # This must be the URL users will use to access Penpot.
          PENPOT_PUBLIC_URI = "https://penpot.mgrlab.dk";

          # --- Secret Key ---
          # IMPORTANT: Replace this with a securely generated key.
          # Use: python3 -c "import secrets; print(secrets.token_urlsafe(64))"
          PENPOT_SECRET_KEY = "gtxe95tqqd7bsvwdze98z2t70l5xufc2f88hcomf9qfaiyf2ffqujwoj7g01qk3";

          # --- Database Connection ---
          PENPOT_DATABASE_URI = "postgresql://penpot-postgres/penpot";
          PENPOT_DATABASE_USERNAME = "penpot";
          PENPOT_DATABASE_PASSWORD = "penpot"; # Must match the postgres service

          # --- Redis Connection ---
          PENPOT_REDIS_URI = "redis://penpot-redis/0";

          # --- Storage Configuration ---
          # Uses the filesystem, with data stored in the mounted volume.
          PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
          PENPOT_STORAGE_ASSETS_FS_DIRECTORY = "/opt/data/assets";

          # --- OIDC Configuration ---
          # IMPORTANT: Replace these with your PocketID instance details.
          PENPOT_OIDC_CLIENT_ID = "346a3181-c9a4-4874-88e5-c9a51753e471";
          PENPOT_OIDC_CLIENT_SECRET = "4nhitE9E8tS47CnI3z1aZFuZN36S4nhi"; # Use a secret for this
          PENPOT_OIDC_BASE_URI = "https://oidc.mgrlab.dk"; # e.g., https://id.mgrlab.dk

          # --- SMTP Configuration ---
          # The 'enable-smtp' flag is set, but you need to configure a real
          # SMTP provider here for emails (like invitations) to work.
          PENPOT_SMTP_HOST = "smtp.simply.com";
          PENPOT_SMTP_PORT = "587";
          PENPOT_SMTP_USERNAME = "home@michael-graversen.dk";
          PENPOT_SMTP_PASSWORD = "niQ8Ug*Z8LtR";
          PENPOT_SMTP_TLS = "true";
          PENPOT_SMTP_SSL = "false";
          PENPOT_SMTP_DEFAULT_FROM = "home@michael-graversen.dk";
          PENPOT_SMTP_DEFAULT_REPLY_TO = "home@michael-graversen.dk";

          # --- Telemetry ---
          # Penpot sends anonymous usage data to help improve the product.
          # Set to "false" to disable.
          PENPOT_TELEMETRY_ENABLED = "true";
        };
        volumes = [
          "/mnt/ssd/services/penpot/assets:/opt/data/assets:rw"
        ];
      };

      # ---------------------
      # --- Penpot Exporter ---
      # ---------------------
      penpot-exporter = {
        image = "penpotapp/exporter:latest";
        networking = {
          networks = [ "default" ];
          aliases = [ "penpot-exporter" ];
        };
        dependsOn = [ "penpot-redis" ];
        environment = {
          # This URI uses the internal container network to communicate with the frontend.
          PENPOT_PUBLIC_URI = "http://penpot-frontend:8080";
          PENPOT_REDIS_URI = "redis://penpot-redis/0";
        };
      };

      # ---------------------
      # --- Penpot Frontend ---
      # ---------------------
      penpot-frontend = {
        image = "penpotapp/frontend:latest";
        networking = {
          networks = [ "default" ];
          aliases = [ "penpot-frontend" ];
          ports.webui = {
            host = 9876;
            internal = 8080;
            protocol = "tcp";
          };
        };
        dependsOn = [
          "penpot-backend"
          "penpot-exporter"
        ];
        environment = {
          # The frontend only needs the flags to correctly render UI elements.
          PENPOT_FLAGS =
            [
              "enable-smtp"
              "enable-log-emails"
              "enable-prepl-server"
              "enable-login-with-oidc"
              "enable-oidc-registration"
            ]
            |> builtins.concatStringsSep " ";

          PENPOT_BACKEND_URI = "http://penpot-backend:6060";
          PENPOT_EXPORTER_URI = "http://penpot-exporter:6061";

          # Max body size (30MiB); Used for plain requests, should never be
          # greater than multi-part size
          PENPOT_HTTP_SERVER_MAX_BODY_SIZE = "31457280";
          # Max multipart body size (350MiB)
          PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE = "367001600";
        };
        volumes = [
          "/mnt/ssd/services/penpot/assets:/opt/data/assets:ro"
        ];
      };
    };
  };
}
