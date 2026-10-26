{
  config,
  lib,
  pkgs,
  ...
}:
let
  package = pkgs.stalwart_0_16;
  dataDir = "/var/lib/stalwart-16";
  user = "stalwart-16";
  group = "stalwart-16";
  configPath = "${dataDir}/config.json";
  planPath = "${dataDir}/settings.ndjson";
  configFile = (pkgs.formats.json { }).generate "stalwart-16-config.json" {
    "@type" = "RocksDb";
    path = "${dataDir}/db";
  };
  upsert = object: matchOn: value: {
    "@type" = "upsert";
    inherit object matchOn value;
  };
  update = object: value: {
    "@type" = "update";
    inherit object value;
  };
  listener = name: address: protocol: tlsImplicit: {
    inherit name protocol tlsImplicit;
    bind.${address} = true;
    useTls = protocol != "http";
  };
  # v0.16 stores settings as JMAP objects, not TOML. Keep this plan idempotent:
  # https://github.com/stalwartlabs/stalwart/blob/v0.16.23/UPGRADING/v0_16.md
  # Field names follow the pinned v0.16.23 schema (e.g. tlsImplicit/sourceIps).
  planFile = pkgs.writeText "stalwart-16-settings.ndjson" (
    lib.concatMapStrings (operation: builtins.toJSON operation + "\n") [
      (upsert "Domain" [ "name" ] {
        mail-domain = {
          name = "mgrlab.dk";
          certificateManagement."@type" = "Manual";
          dnsManagement."@type" = "Manual";
        };
      })
      (upsert "Certificate" [ "certificate" ] {
        mail-certificate = {
          certificate = {
            "@type" = "File";
            filePath = "/var/lib/acme/mail.mgrlab.dk/fullchain.pem";
          };
          privateKey = {
            "@type" = "File";
            filePath = "/var/lib/acme/mail.mgrlab.dk/key.pem";
          };
        };
      })
      (update "SystemSettings" {
        defaultHostname = "mail.mgrlab.dk";
        defaultDomainId = "#mail-domain";
        defaultCertificateId = "#mail-certificate";
      })
      (upsert "NetworkListener" [ "name" ] {
        smtp = listener "smtp" "[::]:25" "smtp" false;
        submission = listener "submission" "[::]:587" "smtp" false;
        submissions = listener "submissions" "[::]:465" "smtp" true;
        imaptls = listener "imaptls" "[::]:993" "imap" true;
        # Local Pangolin resources reach the host over the Podman bridge.
        http = listener "http" "0.0.0.0:4848" "http" false;
      })
      (update "Http" { useXForwarded = true; })
      (upsert "Tracer" [ "@type" ] {
        journal = {
          "@type" = "Journal";
          enable = true;
          level = "info";
        };
      })
      (upsert "Application" [ "description" ] {
        webui = {
          description = "Stalwart Web Interface";
          enabled = true;
          resourceUrl = "file://${package.webui}/webui.zip";
          urlPrefix = {
            "/admin" = true;
            "/account" = true;
          };
          unpackDirectory = "${dataDir}/webui";
        };
      })
      (update "SpamSettings" {
        spamFilterRulesUrl = "file://${package.spam-filter}/spam-filter-rules.json.gz";
      })
      (upsert "MtaConnectionStrategy" [ "name" ] {
        default = {
          name = "default";
          # Publish IPv6 forward DNS and SPF before using the Hetzner IPv6 source.
          sourceIps."0".sourceIp = "138.199.154.23";
        };
      })
    ]
  );
in
{
  # Manually reproduce the nixpkgs service: services.stalwart only supports v0.15.
  # Never open/migrate the v0.15 test database or reuse its webadmin cache.
  users.groups.${group} = { };
  users.users.${user} = {
    isSystemUser = true;
    inherit group;
  };

  environment.systemPackages = [
    package
    pkgs.stalwart-cli
  ];

  # Mail protocols terminate at Stalwart, not the Pangolin containers.
  networking.firewall.allowedTCPPorts = [
    25
    465
    587
    993
  ];

  # Local Pangolin's Traefik reaches 4848 via the tunnel Podman bridge only.
  networking.firewall.interfaces.podman1.allowedTCPPorts = [ 4848 ];

  security.acme = {
    acceptTerms = true;
    certs."mail.mgrlab.dk" = {
      email = "home@michael-graversen.dk";
      dnsProvider = "cloudflare";
      # Avoid the host's caching stub when checking DNS-01 propagation.
      dnsResolver = "1.1.1.1:53";
      environmentFile = pkgs.writeText "stalwart-acme-cloudflare.env" ''
        CF_API_EMAIL=home@michael-graversen.dk
      '';
      credentialFiles.CF_API_KEY_FILE = config.sops.secrets.CLOUDFLARE_GLOBAL_API_KEY.path;
      inherit group;
      reloadServices = [ "stalwart.service" ];
    };
  };

  systemd.services.stalwart = {
    description = "Stalwart Server v0.16";
    wantedBy = [ "multi-user.target" ];
    requires = [ "acme-mail.mgrlab.dk.service" ];
    after = [
      "local-fs.target"
      "network.target"
      "acme-mail.mgrlab.dk.service"
    ];
    path = [ pkgs.stalwart-cli ];
    environment = {
      STALWART_HOSTNAME = "mail.mgrlab.dk";
      STALWART_PUBLIC_URL = "https://mail.mgrlab.dk";
      # The CLI writes its schema cache before making API requests. The system
      # user's default HOME (/var/empty) is not writable, including in preStart.
      XDG_CACHE_HOME = "${dataDir}/cache";
    };

    # Apply only the settings above before opening mail listeners. Recovery mode
    # binds all interfaces, so its temporary port must stay closed in the firewall.
    # Reapplying on each start preserves UI-created accounts and other settings.
    preStart = ''
      install -m 0600 ${configFile} ${configPath}
      install -m 0600 ${planFile} ${planPath}

      export STALWART_URL=http://127.0.0.1:18080
      export STALWART_USER=admin
      STALWART_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/user_admin_password")
      export STALWART_PASSWORD
      export STALWART_RECOVERY_ADMIN="admin:$STALWART_PASSWORD"

      STALWART_RECOVERY_MODE=1 STALWART_RECOVERY_MODE_PORT=18080 \
        ${lib.getExe package} --config=${configPath} &
      recoveryPid=$!
      stopRecovery() {
        kill -INT "$recoveryPid" 2>/dev/null || true
        wait "$recoveryPid" || true
      }
      trap stopRecovery EXIT

      ready=false
      for attempt in $(seq 1 60); do
        kill -0 "$recoveryPid"
        if readinessError=$(stalwart-cli query NetworkListener --json 2>&1); then
          ready=true
          break
        fi
        sleep 1
      done
      if [ "$ready" != true ]; then
        echo "Stalwart recovery API did not become ready" >&2
        printf '%s\n' "$readinessError" >&2
        exit 1
      fi
      stalwart-cli apply --file ${planPath}
    '';

    # v0.16's replacement for authentication.fallback-admin. Read the password
    # at runtime rather than putting it in a Nix store file or process arguments.
    script = ''
      export STALWART_RECOVERY_ADMIN="admin:$(<"$CREDENTIALS_DIRECTORY/user_admin_password")"
      exec ${lib.getExe package} --config=${configPath}
    '';

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      StateDirectory = "stalwart-16";
      StateDirectoryMode = "0700";
      WorkingDirectory = dataDir;
      LoadCredential = [
        "user_admin_password:${config.sops.secrets.STALWART_ADMIN_PASSWORD.path}"
      ];
      LimitNOFILE = 65536;
      KillMode = "control-group";
      KillSignal = "SIGINT";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStartSec = 180;
      SyslogIdentifier = "stalwart-16";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

      # Same sandbox as the nixpkgs module, with only the v0.16 state writable.
      DeviceAllow = [ "" ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateUsers = false;
      ProcSubset = "pid";
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      UMask = "0077";
    };
  };
}
