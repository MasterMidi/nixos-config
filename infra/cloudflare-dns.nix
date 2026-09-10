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
    mgrlab_protonmail_dkim_1 = {
      zone = "mgrlab";
      name = "protonmail._domainkey.mgrlab.dk";
      type = "CNAME";
      content = "protonmail.domainkey.dtlsqrfwymr5t7o4otvfpyoaqpjebrr6rwuf7ugka7quh7nxzkc7a.domains.proton.ch";
    };
    mgrlab_protonmail_dkim_2 = {
      zone = "mgrlab";
      name = "protonmail2._domainkey.mgrlab.dk";
      type = "CNAME";
      content = "protonmail2.domainkey.dtlsqrfwymr5t7o4otvfpyoaqpjebrr6rwuf7ugka7quh7nxzkc7a.domains.proton.ch";
    };
    mgrlab_protonmail_dkim_3 = {
      zone = "mgrlab";
      name = "protonmail3._domainkey.mgrlab.dk";
      type = "CNAME";
      content = "protonmail3.domainkey.dtlsqrfwymr5t7o4otvfpyoaqpjebrr6rwuf7ugka7quh7nxzkc7a.domains.proton.ch";
    };
    mgrlab_protonmail_mx_primary = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "MX";
      content = "mail.protonmail.ch";
      priority = 10;
    };
    mgrlab_protonmail_mx_secondary = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "MX";
      content = "mailsec.protonmail.ch";
      priority = 20;
    };
    mgrlab_dmarc = {
      zone = "mgrlab";
      name = "_dmarc.mgrlab.dk";
      type = "TXT";
      content = "v=DMARC1; p=quarantine";
    };
    mgrlab_protonmail_spf = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "TXT";
      content = "v=spf1 include:_spf.protonmail.ch ~all";
    };
    mgrlab_protonmail_verification = {
      zone = "mgrlab";
      name = "mgrlab.dk";
      type = "TXT";
      content = "protonmail-verification=a44008d99f35e12c4692de54f5c5dbc0e6a3f66c";
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

  zoneId = zone: "\${data.cloudflare_zones.${zone}.result[0].id}";
  recordContent = record: if record.type == "TXT" then ''"${record.content}"'' else record.content;

  mkRecord =
    record:
    {
      zone_id = zoneId record.zone;
      inherit (record) name type;
      content = recordContent record;
      ttl = 1;
      proxied = false;
    }
    // lib.optionalAttrs (record ? priority) { inherit (record) priority; };

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

  data.cloudflare_dns_records = lib.mapAttrs (_: mkRecordLookup) records;

  resource.cloudflare_dns_record = lib.mapAttrs (_: mkRecord) records;

  resource.cloudflare_zone_dnssec.mgrlab = {
    zone_id = zoneId "mgrlab";
    status = "active";
  };

  import = lib.mapAttrsToList mkImport records ++ [
    {
      to = "cloudflare_zone_dnssec.mgrlab";
      id = zoneId "mgrlab";
    }
  ];
}
