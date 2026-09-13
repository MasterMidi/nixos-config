# NetBird On Aether

## Status

Phase 1 repository implementation complete. Deployment, DNS application, and
runtime bootstrap remain pending. This plan replaces the Pangolin ingress stack
with a self-hosted NetBird deployment while retaining Tailscale during the
migration.

## Goal

Run the current combined NetBird server on `aether`, connect the existing VPN
hosts with the upstream NixOS NetBird client module, and prepare NetBird's beta
reverse proxy to replace Pangolin.

The public endpoints will be:

- `netbird.mgrlab.dk` for the dashboard and control plane.
- `*.proxy.mgrlab.dk` for automatically named NetBird proxy services.
- Existing root-level names such as `jellyfin.mgrlab.dk` as NetBird custom
  domains.

Pocket ID remains the user-facing identity provider. It will be added as a
connector to NetBird's embedded identity provider after the initial local
owner bootstraps the deployment.

## Decisions

- Define `netbird-server` and `netbird-client` as independent NixOS modules.
- Put both flake-parts module definitions in one dendritic file.
- Import both modules explicitly on `aether`; the server module must not import
  the client module.
- Use `pkgs.netbird-combined` for the server rather than the legacy
  `services.netbird.server` stack.
- Use upstream `services.netbird.clients` for peers.
- Use the NixOS `services.traefik` module as the only public HTTP/TLS ingress on
  `aether`.
- Disable Pangolin, Gerbil, the old containerized Traefik, and both Newt
  agents.
- Keep Tailscale enabled on every host until NetBird has been validated.
- Initially add NetBird alongside Tailscale on `aether`, `andromeda`,
  `meridian`, `zenith`, and `hyperion`.
- Keep local NetBird authentication available as an emergency fallback after
  Pocket ID is connected.

## Why Not Use The Upstream Server Module

The upstream `services.netbird.server` module implements NetBird's older split
architecture. It provides management, signal, dashboard, and optional Coturn
services, but does not configure the newer combined server, embedded identity
provider, relay, or beta reverse-proxy service.

Completing that stack would require custom NixOS services for `netbird-relay`
and `netbird-proxy`, additional management configuration, external OIDC setup,
and replacement proxy routes for paths the module does not currently handle.
That is more custom integration around an architecture NetBird no longer uses
for new installations.

The locked nixpkgs revision currently packages `netbird-combined`,
`netbird-proxy`, `netbird-dashboard`, and the client. Verify their versions and
options with the NixOS MCP server again before implementation because the lock
or unstable channel may have advanced.

## Current State

### VPN clients

The following hosts currently import `self.nixosModules.tailscale`:

- `hosts/aether/default.nix`
- `hosts/andromeda/default.nix`
- `hosts/meridian/default.nix`
- `hosts/zenith/default.nix`
- `hosts/hyperion/default.nix`

The shared module is `dendritic-modules/services/tailscale.nix`. Do not remove
these imports during the initial NetBird deployment.

### Pangolin

`hosts/aether/containers/pangolin/default.nix` declares a compose application
named `tunnel` containing Pangolin, Gerbil, and Traefik. Gerbil currently owns:

- TCP 80 and 443 for Traefik.
- UDP 51820 for its WireGuard tunnel.
- TCP 25, 465, 587, and 993 for planned mail forwarding.

The same compose application also contains the Vaultwarden declaration from
`hosts/aether/containers/vaultwarden.nix`. Removing the Pangolin import removes
the application-level `enable = true`, so Vaultwarden will also become
inactive unless it is moved to another enabled compose application.

There are two active Pangolin Newt declarations to remove from configuration:

- `hosts/andromeda/containers/newt.nix`
- `k8s/newt.nix`

Leave their encrypted secrets in place during the trial. Remove obsolete
secrets only after the migration is complete and rollback is no longer needed.

### Pocket ID

The active Pocket ID declaration is `k8s/pocketid.nix`, imported by
`k8s/default.nix`. It exposes a ClusterIP service named `pocket-id` on TCP 1411
inside the `media-stack` namespace.

Its current public route depends on the Kubernetes Newt agent and Pangolin.
After Pangolin is disabled, `oidc.mgrlab.dk` will remain unavailable until the
K3s service network is reachable through Andromeda and a NetBird reverse proxy
service has been created.

The older OCI Pocket ID declaration at
`hosts/andromeda/containers/pocketid.nix` is not imported and must not be
treated as the active instance.

## Proposed Repository Changes

### Dendritic modules

Add `dendritic-modules/services/netbird.nix` with exactly two exported NixOS
modules:

```nix
{ self, ... }:
{
  flake.nixosModules.netbird-client = { ... }: {
    # Upstream NetBird client configuration.
  };

  flake.nixosModules.netbird-server = { ... }: {
    # Combined server, dashboard, Traefik, and NetBird proxy.
  };
}
```

Do not make `netbird-server` import `netbird-client`.

### Host imports

Add `self.nixosModules.netbird-client` next to the existing Tailscale import in
the five host entry points.

Add both modules explicitly to Aether:

```nix
modules = [
  self.nixosModules.tailscale
  self.nixosModules.netbird-client
  self.nixosModules.netbird-server
  # Existing modules...
];
```

On Andromeda, override the shared client's routing mode so it can route the K3s
service network:

```nix
services.netbird.useRoutingFeatures = "both";
```

Other nodes should use client routing mode and should not enable forwarding.

## Client Module

Use the multi-client interface rather than the backward-compatible
`services.netbird.enable` option:

```nix
services.netbird = {
  useRoutingFeatures = "client";
  clients.mgrlab = {
    port = 51821;
    interface = "nb-mgrlab";
    hardened = true;
    environment.NB_MANAGEMENT_URL = "https://netbird.mgrlab.dk:443";
  };
};
```

UDP 51821 avoids Pangolin's existing UDP 51820 binding during evaluation and
rollback. The client module opens the peer port and the internal interface DNS
ports when its defaults remain enabled.

Do not enable setup-key login until a key has been created by the running
server. In the second bootstrap phase, declare a shared SOPS secret and set:

```nix
services.netbird.clients.mgrlab.login = {
  enable = true;
  setupKeyFile = config.sops.secrets.NETBIRD_SETUP_KEY.path;
  systemdDependencies = [ "sops-install-secrets.service" ];
};
```

The setup key must be encrypted for every host that imports the client module.
Do not place it directly in Nix code or the Nix store.

## Combined Server

Create a hardened `netbird-server.service` around
`pkgs.netbird-combined`/`netbird-server`.

The generated YAML configuration should use:

- `server.listenAddress = "127.0.0.1:8081"`.
- `server.exposedAddress = "https://netbird.mgrlab.dk:443"`.
- Embedded signal and relay services.
- Embedded STUN on UDP 3478.
- Metrics and health listeners restricted to loopback.
- `server.dataDir = "/var/lib/netbird"`.
- SQLite for management, activity, and embedded IdP state.
- Embedded IdP issuer `https://netbird.mgrlab.dk/oauth2`.
- Dashboard redirects at `/nb-auth` and `/nb-silent-auth`.
- CLI redirect `http://localhost:53000/`.
- Local authentication enabled as a recovery path.
- Anonymous metrics disabled.

Persist `/var/lib/netbird` with systemd `StateDirectory`. The service should
run with the minimum permissions that still allow the combined process to bind
UDP 3478 and manage its state. Add restart behavior and standard systemd
hardening that does not prevent STUN or relay operation.

Render the server configuration at runtime with a SOPS template so secret
values never enter the Nix store.

## Dashboard

Use `services.netbird.server.dashboard` only for its dashboard package
templating support; do not enable the legacy complete server stack.

Configure the dashboard for the embedded issuer:

- Management API and gRPC endpoint: `https://netbird.mgrlab.dk`.
- Authority: `https://netbird.mgrlab.dk/oauth2`.
- Audience and client ID: `netbird-dashboard`.
- Scopes: `openid profile email groups`.
- Redirect URI: `/nb-auth`.
- Silent redirect URI: `/nb-silent-auth`.
- Token source appropriate for the combined embedded IdP.

Serve the resulting static derivation with Nginx bound only to
`127.0.0.1:8080`. Nginx is an internal static-file backend; Traefik remains the
only process listening publicly on TCP 80 and 443.

## Traefik

Configure the NixOS `services.traefik` module inside `netbird-server`.

Static configuration must include:

- `web` on TCP 80 with redirect to HTTPS.
- `websecure` on TCP 443.
- Disabled or unlimited idle/read timeouts for long-lived gRPC and WebSocket
  connections.
- A Let's Encrypt resolver using TLS-ALPN for `netbird.mgrlab.dk`.
- Persistent ACME state in Traefik's state directory.

Dynamic HTTP routes for `netbird.mgrlab.dk` must include:

- `/signalexchange.SignalExchange/` to the combined server using h2c.
- `/management.ManagementService/` to the combined server using h2c.
- `/management.ProxyService/` to the combined server using h2c.
- `/relay` to the combined server with WebSocket support.
- `/ws-proxy/` to the combined server with WebSocket support.
- `/api` and `/oauth2` to the combined server over HTTP.
- A low-priority catch-all to the dashboard backend on
  `127.0.0.1:8080`.

Dynamic TCP configuration must add a low-priority TLS passthrough router for
all SNI names except `netbird.mgrlab.dk`. Send that traffic to the local
NetBird proxy on `127.0.0.1:8443` using PROXY protocol v2.

This catch-all allows NetBird to terminate certificates for both
`*.proxy.mgrlab.dk` services and custom root-level domains such as
`jellyfin.mgrlab.dk`. Traefik must not terminate TLS for these service domains.

Only Traefik and STUN should be publicly reachable initially:

- TCP 80
- TCP 443
- UDP 3478
- UDP 51821 for Aether's independently imported NetBird client

Additional TCP or UDP reverse-proxy services require explicit host firewall
ports and matching NetBird proxy listeners. HTTP and TLS services can share
TCP 443 through SNI routing.

## NetBird Proxy

Define `netbird-proxy.service` inside the server module using
`pkgs.netbird-proxy`.

Configure it with:

- `NB_PROXY_DOMAIN=proxy.mgrlab.dk`.
- `NB_PROXY_MANAGEMENT_ADDRESS=http://127.0.0.1:8081`.
- Insecure management transport allowed only for this loopback connection.
- `NB_PROXY_ADDRESS=127.0.0.1:8443`.
- ACME certificates enabled with `tls-alpn-01`.
- Persistent certificate storage under `/var/lib/netbird-proxy`.
- `NB_PROXY_FORWARDED_PROTO=https`.
- PROXY protocol enabled.
- Trusted proxy range restricted to loopback.
- A random WireGuard proxy port unless a fixed one is later required.

The proxy token cannot be generated before the management database exists.
Define the service with a root-only token file and a
`ConditionPathExists`/equivalent guard so the first deployment succeeds while
the proxy remains stopped. After bootstrap, generate the token with the
NetBird server admin CLI, store it in SOPS, point the service credential at the
SOPS path, and start the service.

Do not put the proxy token in an environment string, generated store path, or
world-readable unit definition. Prefer systemd credentials or a root-only
environment file generated by SOPS.

## Secrets

Add Aether-scoped encrypted secrets in
`hosts/aether/secrets/secrets.sops.yaml` and declarations in
`hosts/aether/secrets/default.nix` for:

- `NETBIRD_AUTH_SECRET`: relay authentication secret.
- `NETBIRD_STORE_ENCRYPTION_KEY`: base64-encoded 32-byte store encryption key.
- `NETBIRD_IDP_SESSION_COOKIE_ENCRYPTION_KEY`: valid 16, 24, or 32-byte cookie
  encryption key.
- `NETBIRD_PROXY_TOKEN`: added only after the first server bootstrap.

Add the reusable client key to the shared SOPS file only after creating it:

- `NETBIRD_SETUP_KEY`

Generate values using a cryptographically secure tool. Never use module
examples, placeholders, or values from the Nix store as production secrets.

## Disable Pangolin

Make the following configuration changes:

- Remove `./pangolin` from `hosts/aether/containers/default.nix`.
- Remove `./newt.nix` from `hosts/andromeda/containers/default.nix`.
- Remove `./newt.nix` from `k8s/default.nix` so future Kubernetes manifests do
  not include the Pangolin agent.

Do not delete Pangolin data, certificates, or encrypted secrets during the
trial. They are needed for rollback.

Review the resulting `compose.tunnel` configuration. If the remaining
Vaultwarden fragment creates invalid or misleading configuration, temporarily
remove its import too and document that Vaultwarden is offline pending NetBird
exposure.

The Vaultwarden import was removed because the compose module currently ignores
the application-level `enable` option and would otherwise create a container
that references Pangolin's removed `tunnel-default` network. Its data and
secrets remain untouched; Vaultwarden is offline pending NetBird exposure.

## DNS

`infra/cloudflare-dns.nix` already defines:

- `mgrlab.dk` pointing at Aether.
- `*.mgrlab.dk` pointing at Aether.

These records cover `netbird.mgrlab.dk`, `proxy.mgrlab.dk`,
`oidc.mgrlab.dk`, and custom root services such as
`jellyfin.mgrlab.dk`.

Add an unproxied record for `*.proxy.mgrlab.dk` pointing at Aether. A wildcard
matches only one DNS label, so the existing `*.mgrlab.dk` record does not cover
`service.proxy.mgrlab.dk`.

Apply the Terranix Cloudflare configuration separately from the NixOS build.
Do not assume editing the DNS module changes live DNS.

## Bootstrap Sequence

The migration requires two configuration/deployment phases because setup keys
and proxy tokens are generated by a running management server.

### Phase 1: Control plane

1. Add the independent server and client modules.
2. Add the non-bootstrap server secrets.
3. Add the client module imports with automated login still disabled.
4. Disable the Pangolin and Newt configuration.
5. Add and apply `*.proxy.mgrlab.dk` DNS.
6. Deploy Aether while retaining Tailscale access.
7. Confirm `https://netbird.mgrlab.dk/setup` is reachable.
8. Create the initial local owner account.

### Phase 2: Peers and proxy

1. Create a reusable NetBird setup key.
2. Add it to shared SOPS recipients and enable automated client login.
3. Deploy Aether, Andromeda, Meridian, Zenith, and Hyperion.
4. Confirm every peer connects before making routing changes.
5. Generate an Aether proxy token with the NetBird server admin CLI.
6. Add the proxy token to Aether's SOPS file and enable/start
   `netbird-proxy.service`.
7. Confirm `proxy.mgrlab.dk` appears as a proxy cluster in the dashboard.

## Pocket ID Migration

Pocket ID cannot be the first login mechanism because disabling Pangolin
temporarily removes its public route. Use the local owner only for bootstrap,
then restore Pocket ID through NetBird:

1. Confirm the NetBird client on Andromeda is connected and has routing
   features enabled.
2. Create a NetBird Network resource covering the K3s service network
   `10.43.0.0/16`, or a narrower stable resource for Pocket ID if available.
3. Select Andromeda as the routing peer and create the required access policy.
4. Obtain Pocket ID's current ClusterIP with
   `kubectl -n media-stack get service pocket-id`.
5. Create a NetBird reverse proxy HTTP service with custom domain
   `oidc.mgrlab.dk`, targeting the Pocket ID ClusterIP on TCP 1411.
6. Confirm Pocket ID is publicly reachable before changing authentication.
7. In Pocket ID, create a confidential OIDC client for NetBird and restrict it
   to the intended user group.
8. Add Pocket ID through NetBird's Settings > Identity Providers page.
9. Register the exact callback URL shown by NetBird in Pocket ID.
10. Register `https://netbird.mgrlab.dk/oauth2/logout/callback` when supported.
11. Test Pocket ID login in a private browser session.
12. Enable JWT group synchronization only after confirming Pocket ID includes
    the expected `groups` array claim.
13. Keep the local owner login available for recovery.

The Pocket ID client secret is stored encrypted by NetBird in its database. It
does not need to be duplicated in Nix unless the connector is later provisioned
through the API.

## Verification

Before writing Nix code, re-check every package and option with the NixOS MCP
server against unstable and the repository's locked nixpkgs input.

Format every changed Nix file with `nixfmt`.

Per repository instructions, stage the changes before flake builds:

```bash
git add -A
```

Dry-build every affected host:

```bash
nixos-rebuild dry-build --flake .#aether
nixos-rebuild dry-build --flake .#andromeda
nixos-rebuild dry-build --flake .#meridian
nixos-rebuild dry-build --flake .#zenith
nixos-rebuild dry-build --flake .#hyperion
```

After deployment, verify:

- `netbird-server.service` is healthy and its data survives restart.
- Traefik is the only public listener on TCP 80 and 443.
- UDP 3478 is reachable for STUN.
- `https://netbird.mgrlab.dk/oauth2/.well-known/openid-configuration`
  succeeds.
- Dashboard login and API calls work.
- Management and signal gRPC streams stay connected.
- All five peers report connected to the self-hosted management URL.
- Direct peer traffic uses UDP 51821 where possible.
- Relay fallback works between peers that cannot connect directly.
- `netbird-proxy` registers with management.
- A generated `*.proxy.mgrlab.dk` service receives a valid certificate.
- A custom root domain such as `jellyfin.mgrlab.dk` receives a valid
  certificate.
- Pocket ID login succeeds after its route is restored through NetBird.
- Tailscale remains usable throughout the trial.

## Rollback

If the control plane or proxy fails:

1. Use Tailscale or the provider console to access Aether.
2. Restore the Pangolin import on Aether.
3. Restore both Newt imports.
4. Disable the host Traefik and NetBird server imports if they conflict with
   restored ports.
5. Rebuild Aether and Andromeda.
6. Redeploy the Kubernetes manifests if the K8s Newt import was removed from a
   live deployment.

Do not remove Tailscale, Pangolin state, or old secrets until rollback has been
tested and NetBird has been stable for an agreed period.

## Security Follow-Up

`hosts/aether/containers/headscale.nix` contains a plaintext OIDC client
secret even though the file is not currently imported. Rotate that credential
and remove it from source or migrate it to SOPS. Do not copy or reuse it for
NetBird.

After implementation, evaluate whether this new combined-server service
pattern needs to be documented in `AGENTS.md`. No update is required merely
for placing two existing-style flake module exports in one dendritic file.
