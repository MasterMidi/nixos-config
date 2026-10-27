# Infrastructure with Terranix

## Hetzner Cloud

The `hcloud-aether` configuration adopts all resources currently present in
the Hetzner Cloud project:

- The existing `Aether` server.
- Its IPv4 and IPv6 Primary IPs.
- Their `mail.mgrlab.dk` reverse DNS records.
- The project SSH public key.

The initial inventory was queried from the Hetzner API on 2026-09-10. The
project had no firewalls, private networks, volumes, floating IPs, placement
groups, load balancers, certificates, snapshots, or backups at that time.

All imported resources use OpenTofu `prevent_destroy`. The configuration
otherwise reproduces the existing Hetzner settings, including disabled remote
delete protection and Primary IP auto-deletion, so the first import can be a
no-change operation. Enable Hetzner-side protection in a separate, reviewed
change.

Run the plan first and reject it if it proposes any update, replacement, or
deletion:

```sh
nix run .#hcloud-aether.plan
nix run .#hcloud-aether
```

The API token is read from `hcloud_api_token` in
`infra/secrets/secrets.sops.yaml` unless `HCLOUD_TOKEN` is already set. Local
state is stored under `infra/.terranix/hcloud-aether/` and must be backed up
until a remote backend is configured.

## Cloudflare DNS

This Terranix configuration manages the existing DNS records for
`mgrlab.dk` and `michael-graversen.dk` with OpenTofu and Cloudflare provider
v5. The records were transcribed from the Cloudflare zone exports dated
2026-09-10.

The exported SOA and apex NS records are intentionally omitted because
Cloudflare manages them as part of each zone.

Public DNS also confirms that DNSSEC is active for `mgrlab.dk` and inactive
for `michael-graversen.dk`. The active `mgrlab.dk` DNSSEC configuration is
adopted into state alongside the records.

## API token

Create a scoped Cloudflare API token with these permissions for only the two
zones:

- Zone / Zone / Read
- Zone / DNS / Edit

## First import

Run all commands from the repository root. The configuration looks up each
existing record and uses OpenTofu import blocks to adopt it into local state.
Review the first plan closely before applying it.

```sh
nix run .#cloudflare-dns.plan
nix run .#cloudflare-dns
```

After the initial apply, the import blocks are inert. State and provider files
are stored under `infra/.terranix/cloudflare-dns/`. Although this directory is
in `.gitignore`, some of its files were already tracked, including the local
state file; keep the updated state after applying changes. Back up the state
file until a remote backend is configured; losing it means the records must be
imported again.

For an interactive shell with `tofu`, `plan`, `apply`, `destroy`, and `init`:

```sh
nix develop .#cloudflare-dns
```

Do not run `destroy` unless both DNS zones and their mail records should be
removed.

## Other Cloudflare resources

Useful follow-up resources depend on what is currently enabled in the
Cloudflare account and should be imported before management:

- Zone DNS settings and enabling DNSSEC for `michael-graversen.dk`
- TLS mode, minimum TLS version, HTTPS redirects, and other zone settings
- Redirect, cache, transform, WAF, and rate-limit rulesets
- Cloudflare Tunnels and tunnel routes
- Zero Trust Access applications, policies, groups, and identity providers
- Workers, Pages projects, routes, KV, D1, and R2
- Load balancers, health monitors, and origin pools
- Notifications, log pushes, and account memberships
- Remote OpenTofu state with locking and encryption

## Stalwart mail domain (`michael-graversen.dk`)

The mail records in `infra/cloudflare-dns.nix` use the supplied Stalwart zone
export dated 2026-10-26. MX points to `mail.mgrlab.dk` with priority 10, SPF is
`v=spf1 mx -all`, and DMARC uses `p=reject` with reports sent to
`postmaster@michael-graversen.dk`. Both `v1-ed25519-20261026` and
`v1-rsa-20261026` DKIM selectors are published; the RSA TXT record retains the
export's two concatenated strings.

The records also include CalDAV, CardDAV, IMAPS, JMAP, POP3S, and submissions
SRV discovery, MTA-STS and TLS reporting, UA auto-configuration, `autoconfig`,
and `autodiscover`. All service targets and discovery CNAMEs use
`mail.mgrlab.dk`.

The old Proton DKIM, verification, and secondary MX records are removed. The
existing primary MX, SPF, and DMARC resource names are retained for updates in
the current OpenTofu state, and new or changed mail records are excluded from
the initial-import lookups. The website A records remain managed separately.

Review and apply with:

```sh
nix run .#cloudflare-dns.plan
nix run .#cloudflare-dns
```

### Client autoconfiguration

`hosts/aether/containers/pangolin/default.nix` registers `michael-graversen.dk`
with Pangolin and declares Traefik file-provider routes for
`autoconfig.michael-graversen.dk`, `autodiscover.michael-graversen.dk`, and
`ua-auto-config.michael-graversen.dk`. These routes forward directly to
Stalwart at `http://host.containers.internal:4848`, preserving paths and query
strings without Pangolin authentication. HTTP redirects to HTTPS. The existing
Cloudflare DNS-01 resolver obtains a certificate for `michael-graversen.dk`
and `*.michael-graversen.dk`; HTTPS terminates at Traefik.

The discovery routes are managed in Nix, so no additional Pangolin UI resources
are needed for these three hostnames. Deploy Aether after reviewing the changes:

```sh
nixos-rebuild dry-build --flake .#aether
dply .#aether
```

Stalwart generates the Thunderbird XML from its advertised services. With the
domain and mailbox configured in Stalwart, check that the public endpoint
returns XML without a certificate error or login redirect:

```sh
curl --fail --show-error \
  'https://autoconfig.michael-graversen.dk/mail/config-v1.1.xml?emailaddress=you%40michael-graversen.dk'
```

The XML should advertise IMAP at `mail.mgrlab.dk:993` and SMTP submission at
`mail.mgrlab.dk:465`, both with implicit TLS and the full email address as the
username. Thunderbird can then discover those settings during account setup.

## Stalwart test domain (`mgrlab.dk`)

`hosts/aether/mailserver.nix` serves SMTP (25), submission (587/465), and
IMAPS (993) directly on Aether. In the Pangolin UI create a **Local Site** and
a public HTTP resource for `mail.mgrlab.dk`, with a target of
`http://host.containers.internal:4848` (Traefik runs inside the Gerbil Podman
network). Route the whole hostname, including `/.well-known/`, `/jmap/`, and
`/admin`; disable Pangolin authentication on this resource so mail clients can
use Stalwart's own JMAP and OAuth authentication. Stalwart's HTTP listener
accepts traffic from the Podman bridge, not the public firewall. NixOS ACME
obtains a separate certificate for `mail.mgrlab.dk` using the existing
Cloudflare API key; Stalwart needs this certificate for SMTP STARTTLS and
IMAPS. DNS currently publishes only the verified IPv4 address; do not publish
an AAAA record until the address with working inbound IPv6 has been checked on
Aether.

The `mgrlab.dk` MX and SPF records switch from Proton to Aether; the old
Proton DKIM, verification, and backup MX records are removed. DMARC uses the
v0.16 export's `p=reject` policy with reports sent to `postmaster@mgrlab.dk`.
The renamed records are **already imported** into the
local `infra/.terranix/cloudflare-dns/terraform.tfstate`; restore that state
from backup if necessary before applying, or explicitly re-import the existing
Cloudflare records. Otherwise the old Proton records will remain unmanaged.
Deploy Aether first and check that Stalwart is running. DNS-01 certificate
issuance works with the current wildcard A record. Sign in at
`https://mail.mgrlab.dk/admin` as `admin` with `STALWART_ADMIN_PASSWORD` from
Aether's SOPS secrets, and create a mailbox in the preconfigured `mgrlab.dk`
domain. `infra/cloudflare-dns.nix` contains the `v1-ed25519-20261026` and
`v1-rsa-20261026` DKIM records from the v0.16 zone export. The v0.15 selectors
`202610e` and `202610r` remain published for previously signed test messages.
IMAPS/submission discovery, HTTPS JMAP/CalDAV/CardDAV discovery through the
existing Pangolin resource, and SMTP TLS reporting are also configured.
Create a mailbox or alias for `postmaster@mgrlab.dk` before applying DNS so it
can receive reports, and update the DKIM records whenever Stalwart rotates its
keys. The generated SPF values using `a`/`mx`
describe the same IPv4 server already authorized by the existing, explicit
`ip4:` SPF records; publish only one SPF record per name.

The v0.16 export is adapted to the active services rather than copied wholesale:

- POP3S (`_pop3s` and port 995 TLSA records) is omitted because no POP3 listener
  is enabled.
- New `mta-sts`, `ua-auto-config`, and `autodiscover` aliases are deferred until
  their HTTPS hostnames are routed through Pangolin with valid certificates.
  Their associated `_mta-sts` and `_ua-auto-config` TXT records are deferred with
  them. The existing `autoconfig.mgrlab.dk` CNAME is retained from Cloudflare
  state, but its `/mail/config-v1.1.xml` endpoint still returns 404 and needs a
  Pangolin route before Thunderbird autoconfiguration can use it.
- TLSA records are omitted until their hashes are verified against the actual
  public endpoints and publication is tied to certificate renewal. Mail ports
  use NixOS ACME, while HTTPS terminates at Pangolin and may use a different
  certificate. DNSSEC is already enabled; stale TLSA hashes could cause
  DANE-aware senders to reject mail.

The NixOS ACME client creates its own short-lived TXT record at
`_acme-challenge.mail.mgrlab.dk`. A separate placeholder TXT record is kept at
that name with a 60-second TTL: without it, Cloudflare's DNSSEC-signed negative
response can remain cached for 30 minutes and hide the challenge until the
certificate order times out. The ACME client checks propagation through
`1.1.1.1` instead of Aether's local caching stub, and removes only its own
TXT value.
After publishing the placeholder, allow old negative caches to expire (up to
30 minutes), then check `acme-order-renew-mail.mgrlab.dk.service` on Aether and
confirm that SMTP on port 25 presents a publicly trusted certificate. Stalwart
serves a temporary self-signed certificate until that ACME order succeeds;
Thunderbird's certificate warning and the SMTP `UnknownIssuer` error indicate
that it is still serving the temporary one. A missing TLSA record is expected;
public validating DNS resolvers return an authenticated empty answer, so don't
publish the TLSA hashes from Stalwart's zonefile to silence its diagnostic.

```sh
nixos-rebuild dry-build --flake .#aether
dply .#aether
```

After the domain and mailboxes are ready, review and apply DNS:

```sh
nix run .#cloudflare-dns.plan
nix run .#cloudflare-dns
```

Verify that a sent message passes DKIM and SPF with the new v0.16 selectors.
Check that Hetzner permits inbound/outbound port 25, and test a message in each
direction before relying on the new MX record.
