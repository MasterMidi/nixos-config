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
are stored under `infra/.terranix/cloudflare-dns/`, which is git-ignored. Back
up the state file until a remote backend is configured; losing it means the
records must be imported again.

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

Cloudflare cannot expose Proton Mail account configuration through this DNS
provider. The Proton records for `michael-graversen.dk` are managed here as
ordinary DNS records.

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
Proton DKIM, verification, and backup MX records are removed. DMARC is set to
`p=none` during setup. The renamed records are **already imported** into the
local `infra/.terranix/cloudflare-dns/terraform.tfstate`; restore that state
from backup if necessary before applying, or explicitly re-import the existing
Cloudflare records. Otherwise the old Proton records will remain unmanaged.
Deploy Aether first and check that Stalwart is running. DNS-01 certificate
issuance works with the current wildcard A record. Sign in at
`https://mail.mgrlab.dk/admin` as `admin` with `STALWART_ADMIN_PASSWORD` from
Aether's SOPS secrets, and create the `mgrlab.dk` domain and a mailbox.
`infra/cloudflare-dns.nix` contains the `202610e` and `202610r` DKIM records
generated by Stalwart for this domain, along with IMAPS/submission discovery
and SMTP TLS reporting. Create a mailbox or alias for `postmaster@mgrlab.dk`
before applying DNS so it can receive reports, and update the DKIM records
whenever Stalwart rotates its keys. The generated SPF values using `a`/`mx`
describe the same IPv4 server already authorized by the existing, explicit
`ip4:` SPF records; publish only one SPF record per name.

Do not publish the generated `_25._tcp.mail` TLSA hashes: Stalwart's zonefile
describes its own certificate, but Aether actually presents a separately
renewed NixOS ACME certificate on port 25. DNSSEC is already enabled; publishing
stale TLSA hashes would cause DANE-aware senders to reject mail. Set up TLSA
publication tied to the NixOS certificate's renewal before enabling DANE.

```sh
nixos-rebuild dry-build --flake .#aether
dply .#aether
```

After the domain and mailboxes are ready, review and apply DNS:

```sh
nix run .#cloudflare-dns.plan
nix run .#cloudflare-dns
```

Once a sent message passes DKIM and SPF, change `_dmarc.mgrlab.dk` back to
`p=quarantine` (or the zonefile's `p=reject`), and add reporting addresses when
the postmaster mailbox is ready. Check that Hetzner permits inbound/outbound
port 25, and test a message in each direction before relying on the new MX
record.
