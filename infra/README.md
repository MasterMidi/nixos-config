# Cloudflare DNS with Terranix

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
provider. The Proton verification, MX, SPF, DKIM, and DMARC records are managed
here as ordinary DNS records.
