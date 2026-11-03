{ lib, pkgs, ... }:

let
  zones = {
    mgrlab = "mgrlab.dk";
    michael_graversen = "michael-graversen.dk";
  };

  records = {
    mgrlab_apex_a = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "A";
      content = "138.199.154.23";
    };
    mgrlab_wildcard_a = {
      zone = "mgrlab";
      name = "*.mgrlab.dk";
      type = "A";
      content = "138.199.154.23";
    };
    mgrlab_www_a = {
      zone = "mgrlab";
      name = "www.mgrlab.dk";
      type = "A";
      content = "138.199.154.23";
    };
    mgrlab_mail_a = {
      zone = "mgrlab";
      name = "mail.mgrlab.dk";
      type = "A";
      content = "138.199.154.23";
    };
    # Keep this name present between ACME DNS-01 challenges. Otherwise a
    # cached NODATA response can hide the short-lived challenge for 30 minutes.
    mgrlab_mail_acme_challenge = {
      zone = "mgrlab";
      name = "_acme-challenge.mail.mgrlab.dk";
      type = "TXT";
      content = "acme-dns01-placeholder";
      ttl = 60;
    };
    # Keep the imported resource names so OpenTofu updates these records in place.
    mgrlab_protonmail_mx_primary = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "MX";
      content = "mail.mgrlab.dk";
      priority = 10;
    };
    mgrlab_dmarc = {
      zone = "mgrlab";
      name = "_dmarc.mgrlab.dk";
      type = "TXT";
      content = "v=DMARC1; p=reject; rua=mailto:postmaster@mgrlab.dk";
    };
    mgrlab_protonmail_spf = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "TXT";
      content = "v=spf1 ip4:138.199.154.23 -all";
    };
    mgrlab_mail_spf = {
      zone = "mgrlab";
      name = "mail.mgrlab.dk";
      type = "TXT";
      content = "v=spf1 ip4:138.199.154.23 -all";
    };
    # Retain v0.15 selectors so previously signed test messages still verify.
    mgrlab_dkim_ed25519 = {
      zone = "mgrlab";
      name = "202610e._domainkey.mgrlab.dk";
      type = "TXT";
      content = "v=DKIM1; k=ed25519; h=sha256; p=+VIjlSQiH5N6TPj1OoKNcZ4YgFEm3vZhhgeJVMucI6M=";
    };
    mgrlab_dkim_rsa = {
      zone = "mgrlab";
      name = "202610r._domainkey.mgrlab.dk";
      type = "TXT";
      # A single TXT record with two strings; DNS clients concatenate them.
      content = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyStwcxBckWhZ6SPXEhz3ZbHwTG3gOxO3MDN+Zr4EYTvU43CIXuz+aQ/O8PMM61TP3bPJaNESNSpGj6H2wxpCLib7RDtaD7rDmaofrPBrDZRd7pftLiZf1yGO50RosG0HEuHpK7ONsJ1wkEY/trKQpv8Vlh68NHPjLv4HVpZO40JN13bF2NjikwT"
        "oGv2mnSuBhZ48USCWMkdmOoCz8QiGsP2mOIQioU8rcz97v2qkv9cCUlKi2qdHd36svEDQGJFSXDrLPOsHM2Yjg0TmFdThP6gQuq3KbxMtimf6lL3h+NeNUNW7fkXKs2U5bTGdxW20gUm1smb8n/KcfwCAzf6CAwIDAQAB"
      ];
    };
    mgrlab_dkim_v16_ed25519 = {
      zone = "mgrlab";
      name = "v1-ed25519-20261026._domainkey.mgrlab.dk";
      type = "TXT";
      content = "v=DKIM1; k=ed25519; h=sha256; p=pCfKjC6sVm9iYP9zII0PAZbPELrMAa8cDAkBybR50+A=";
    };
    mgrlab_dkim_v16_rsa = {
      zone = "mgrlab";
      name = "v1-rsa-20261026._domainkey.mgrlab.dk";
      type = "TXT";
      content = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzQde9pikgpBF50hm8kEt1G7OTy68tdjjlTzH8trip9fNNcYdxy0TOozQXYf7X9z62NR0aV3uuP9eWmY/jJfiXeFupXpwhETo3UsIOlkiiqHoy3wL6nLgUaSXa6pmsvIDh4sm/xJC4m0y3/uEeJECtp2kYk8K/QG2PK0w4gfpbOZ/81UnW6NDvjS"
        "PTMUnTos0YQcv/fAGvMR3ajp0QZVqq16Pp0ha3CKDfWvxgIXetWr3iGw3luMmHW6KrwBvUGIv/r0yGR5TKzcW3pdxt9DtHTVINFIPdZzYi6BA7HRMFb3S0q1iiff3TXZgSnMorSjbo6EQG9BjoEhh5xUZaLMG0QIDAQAB"
      ];
    };
    # These HTTPS services use the existing mail.mgrlab.dk Pangolin resource.
    mgrlab_caldavs_srv = {
      zone = "mgrlab";
      name = "_caldavs._tcp.mgrlab.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 443;
        target = "mail.mgrlab.dk";
      };
    };
    mgrlab_carddavs_srv = {
      zone = "mgrlab";
      name = "_carddavs._tcp.mgrlab.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 443;
        target = "mail.mgrlab.dk";
      };
    };
    mgrlab_jmap_srv = {
      zone = "mgrlab";
      name = "_jmap._tcp.mgrlab.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 443;
        target = "mail.mgrlab.dk";
      };
    };
    # Already present in Cloudflare and state; preserve it while the remaining
    # v0.16 discovery aliases await Pangolin routes.
    mgrlab_autoconfig_cname = {
      zone = "mgrlab";
      name = "autoconfig.mgrlab.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
    };
    mgrlab_imaps_srv = {
      zone = "mgrlab";
      name = "_imaps._tcp.mgrlab.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 993;
        target = "mail.mgrlab.dk";
      };
    };
    mgrlab_submissions_srv = {
      zone = "mgrlab";
      name = "_submissions._tcp.mgrlab.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 465;
        target = "mail.mgrlab.dk";
      };
    };
    mgrlab_submission_srv = {
      zone = "mgrlab";
      name = "_submission._tcp.mgrlab.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 587;
        target = "mail.mgrlab.dk";
      };
    };
    mgrlab_tls_reports = {
      zone = "mgrlab";
      name = "_smtp._tls.mgrlab.dk";
      type = "TXT";
      content = "v=TLSRPTv1; rua=mailto:postmaster@mgrlab.dk";
    };

    michael_graversen_apex_a = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "A";
      content = "93.191.156.253";
    };
    michael_graversen_www_a = {
      zone = "michael_graversen";
      name = "www.michael-graversen.dk";
      type = "A";
      content = "93.191.156.253";
    };
    michael_graversen_dmarc = {
      zone = "michael_graversen";
      name = "_dmarc.michael-graversen.dk";
      type = "TXT";
      content = "v=DMARC1; p=reject; rua=mailto:postmaster@michael-graversen.dk";
    };
    michael_graversen_dkim_v16_ed25519 = {
      zone = "michael_graversen";
      name = "v1-ed25519-20261026._domainkey.michael-graversen.dk";
      type = "TXT";
      content = "v=DKIM1; k=ed25519; h=sha256; p=tBurFvNwm/YnBY7Ys+3PLnsNdzkPT3Pgv/F+MeyV0ok=";
    };
    michael_graversen_dkim_v16_rsa = {
      zone = "michael_graversen";
      name = "v1-rsa-20261026._domainkey.michael-graversen.dk";
      type = "TXT";
      content = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtSYjkiVRgmefdGYIuPCySOl+yfa8r0CA8R8TDdMVmk4mIbguTfTXbfg3ZB7d4M6nMWFS3zzUTspr1gutnGHEi28T6ACshIBfMJoIuCxwz2gMTXdhmlcf8TfpzQOO2FxwuAeddjUCXZeelCmEWtpAUzbftTQ4XHOSJMh+s21sgM8OSPSw/KtCusW"
        "gZoWT4ws9xT0z9Sp8Tg1Ce1fEFsC46Ma5mW8G1jOohKFPxB99nLppwyOYV8dySFwUf2p84QLZryZDg6DoLb4ozk5DTqg5FpEUWLebhqz7jFbcYyH5dXuraol9yfZQfXVRw0zTXSp/ieFYXmJmxifo8u7l/H+0JwIDAQAB"
      ];
    };
    # Keep the imported resource names so OpenTofu updates these records in place.
    michael_graversen_protonmail_mx_primary = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "MX";
      content = "mail.mgrlab.dk";
      priority = 10;
    };
    michael_graversen_protonmail_spf = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "TXT";
      content = "v=spf1 mx -all";
    };
    michael_graversen_caldavs_srv = {
      zone = "michael_graversen";
      name = "_caldavs._tcp.michael-graversen.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 443;
        target = "mail.mgrlab.dk";
      };
    };
    michael_graversen_carddavs_srv = {
      zone = "michael_graversen";
      name = "_carddavs._tcp.michael-graversen.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 443;
        target = "mail.mgrlab.dk";
      };
    };
    michael_graversen_imaps_srv = {
      zone = "michael_graversen";
      name = "_imaps._tcp.michael-graversen.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 993;
        target = "mail.mgrlab.dk";
      };
    };
    michael_graversen_jmap_srv = {
      zone = "michael_graversen";
      name = "_jmap._tcp.michael-graversen.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 443;
        target = "mail.mgrlab.dk";
      };
    };
    michael_graversen_pop3s_srv = {
      zone = "michael_graversen";
      name = "_pop3s._tcp.michael-graversen.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 995;
        target = "mail.mgrlab.dk";
      };
    };
    michael_graversen_submissions_srv = {
      zone = "michael_graversen";
      name = "_submissions._tcp.michael-graversen.dk";
      type = "SRV";
      priority = 0;
      data = {
        priority = 0;
        weight = 1;
        port = 465;
        target = "mail.mgrlab.dk";
      };
    };
    michael_graversen_mta_sts_cname = {
      zone = "michael_graversen";
      name = "mta-sts.michael-graversen.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
    };
    michael_graversen_mta_sts = {
      zone = "michael_graversen";
      name = "_mta-sts.michael-graversen.dk";
      type = "TXT";
      content = "v=STSv1; id=12055640984192404345";
    };
    michael_graversen_tls_reports = {
      zone = "michael_graversen";
      name = "_smtp._tls.michael-graversen.dk";
      type = "TXT";
      content = "v=TLSRPTv1; rua=mailto:postmaster@michael-graversen.dk";
    };
    michael_graversen_ua_auto_config_cname = {
      zone = "michael_graversen";
      name = "ua-auto-config.michael-graversen.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
    };
    michael_graversen_ua_auto_config = {
      zone = "michael_graversen";
      name = "_ua-auto-config.michael-graversen.dk";
      type = "TXT";
      content = "v=UAAC1; a=sha256; d=CkJioiGlP2VCLh4pXYutLCDlUwJ0Lq29gbcWK908Kvs=";
    };
    michael_graversen_autoconfig_cname = {
      zone = "michael_graversen";
      name = "autoconfig.michael-graversen.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
    };
    michael_graversen_autodiscover_cname = {
      zone = "michael_graversen";
      name = "autodiscover.michael-graversen.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
    };
    # JMAP clients that discover from the email domain (Sterna Mail) probe
    # mail.<domain> because the apex is the external website, not Stalwart.
    michael_graversen_mail_cname = {
      zone = "michael_graversen";
      name = "mail.michael-graversen.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
    };
  };

  # These records are already in state; looking them up by their previous
  # contents would break every plan after switching their DNS values.
  importRecords = lib.removeAttrs records [
    "mgrlab_mail_a"
    "mgrlab_mail_acme_challenge"
    "mgrlab_mail_spf"
    "mgrlab_protonmail_mx_primary"
    "mgrlab_protonmail_spf"
    "mgrlab_dmarc"
    "mgrlab_dkim_ed25519"
    "mgrlab_dkim_rsa"
    # New v0.16 records are created rather than looked up for import.
    "mgrlab_dkim_v16_ed25519"
    "mgrlab_dkim_v16_rsa"
    "mgrlab_caldavs_srv"
    "mgrlab_carddavs_srv"
    "mgrlab_jmap_srv"
    "mgrlab_autoconfig_cname"
    "mgrlab_imaps_srv"
    "mgrlab_submissions_srv"
    "mgrlab_submission_srv"
    "mgrlab_tls_reports"
    "michael_graversen_dmarc"
    "michael_graversen_protonmail_mx_primary"
    "michael_graversen_protonmail_spf"
    # New mail records are created rather than looked up for import.
    "michael_graversen_dkim_v16_ed25519"
    "michael_graversen_dkim_v16_rsa"
    "michael_graversen_caldavs_srv"
    "michael_graversen_carddavs_srv"
    "michael_graversen_imaps_srv"
    "michael_graversen_jmap_srv"
    "michael_graversen_pop3s_srv"
    "michael_graversen_submissions_srv"
    "michael_graversen_mta_sts_cname"
    "michael_graversen_mta_sts"
    "michael_graversen_tls_reports"
    "michael_graversen_ua_auto_config_cname"
    "michael_graversen_ua_auto_config"
    "michael_graversen_autoconfig_cname"
    "michael_graversen_autodiscover_cname"
  ];

  zoneId = zone: "\${data.cloudflare_zones.${zone}.result[0].id}";
  recordContent =
    record:
    if record.type == "TXT" then
      if builtins.isList record.content then
        lib.concatMapStringsSep " " (part: ''"${part}"'') record.content
      else
        ''"${record.content}"''
    else
      record.content;

  mkRecord =
    record:
    {
      zone_id = zoneId record.zone;
      inherit (record) name type;
      ttl = record.ttl or 1;
      proxied = false;
    }
    // lib.optionalAttrs (record ? content) { content = recordContent record; }
    // lib.optionalAttrs (record ? priority) { inherit (record) priority; }
    // lib.optionalAttrs (record ? data) { inherit (record) data; };

  mkRecordLookup = record: {
    zone_id = zoneId record.zone;
    name.exact = record.name;
    content.exact = recordContent record;
    inherit (record) type;
    max_items = 1;
  };

  mkImport = name: record: {
    to = "cloudflare_dns_record.${name}";
    id = "${zoneId record.zone}/\${data.cloudflare_dns_records.${name}.result[0].id}";
  };
in
{
  terraform.required_providers.cloudflare = {
    source = "cloudflare/cloudflare";
    version = "= ${pkgs.terraform-providers.cloudflare_cloudflare.version}";
  };

  data.cloudflare_zones = lib.mapAttrs (_: name: {
    inherit name;
    max_items = 1;
  }) zones;

  data.cloudflare_dns_records = lib.mapAttrs (_: mkRecordLookup) importRecords;

  resource.cloudflare_dns_record = lib.mapAttrs (_: mkRecord) records;

  resource.cloudflare_zone_dnssec.mgrlab = {
    zone_id = zoneId "mgrlab";
    status = "active";
  };

  import = lib.mapAttrsToList mkImport importRecords ++ [
    {
      to = "cloudflare_zone_dnssec.mgrlab";
      id = zoneId "mgrlab";
    }
  ];
}
