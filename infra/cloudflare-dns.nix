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
    mgrlab_autoconfig_cname = {
      zone = "mgrlab";
      name = "autoconfig.mgrlab.dk";
      type = "CNAME";
      content = "mail.mgrlab.dk";
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
      content = "v=DMARC1; p=none";
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
      type = "CNAME";
      content = "dmarc.simply.com";
    };
    michael_graversen_protonmail_dkim_1 = {
      zone = "michael_graversen";
      name = "protonmail._domainkey.michael-graversen.dk";
      type = "CNAME";
      content = "protonmail.domainkey.dpagdvey2k7rnowvdupchpqwebftokfb4jsk2yw33tz2en2k66p2q.domains.proton.ch";
    };
    michael_graversen_protonmail_dkim_2 = {
      zone = "michael_graversen";
      name = "protonmail2._domainkey.michael-graversen.dk";
      type = "CNAME";
      content = "protonmail2.domainkey.dpagdvey2k7rnowvdupchpqwebftokfb4jsk2yw33tz2en2k66p2q.domains.proton.ch";
    };
    michael_graversen_protonmail_dkim_3 = {
      zone = "michael_graversen";
      name = "protonmail3._domainkey.michael-graversen.dk";
      type = "CNAME";
      content = "protonmail3.domainkey.dpagdvey2k7rnowvdupchpqwebftokfb4jsk2yw33tz2en2k66p2q.domains.proton.ch";
    };
    michael_graversen_protonmail_mx_primary = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "MX";
      content = "mail.protonmail.ch";
      priority = 10;
    };
    michael_graversen_protonmail_mx_secondary = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "MX";
      content = "mailsec.protonmail.ch";
      priority = 20;
    };
    michael_graversen_protonmail_spf = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "TXT";
      content = "v=spf1 include:_spf.protonmail.ch ~all";
    };
    michael_graversen_protonmail_verification = {
      zone = "michael_graversen";
      name = "michael-graversen.dk";
      type = "TXT";
      content = "protonmail-verification=783fa7039b5934348a359a87494de2c0e6a4be9e";
    };
  };

  # These records are already in state; looking them up by their previous
  # contents would break every plan after switching their DNS values.
  importRecords = lib.removeAttrs records [
    "mgrlab_mail_a"
    "mgrlab_autoconfig_cname"
    "mgrlab_mail_spf"
    "mgrlab_protonmail_mx_primary"
    "mgrlab_protonmail_spf"
    "mgrlab_dmarc"
    "mgrlab_dkim_ed25519"
    "mgrlab_dkim_rsa"
    "mgrlab_imaps_srv"
    "mgrlab_submissions_srv"
    "mgrlab_submission_srv"
    "mgrlab_tls_reports"
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
      ttl = 1;
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
