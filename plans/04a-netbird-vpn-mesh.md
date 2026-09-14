# NetBird VPN Mesh On Aether

## Status

Proposed alternative to `04-netbird-aether.md`.

This plan is written against Jujutsu change `zw`
(`zwwztvyqywrpmwxmuwoqlltvptruoomn`), before the implementation in change
`kxl`. It describes the desired changes as a fresh implementation from that
baseline rather than as edits to the proxy-focused attempt.

## Goal

Run a self-hosted NetBird VPN control plane on `aether` and connect the
existing Tailscale hosts to a parallel NetBird mesh.

This is a migration trial, not the removal of Tailscale. Tailscale must remain
enabled and usable on every machine, especially for access to `aether`, until
NetBird has been validated separately.

Pangolin remains the public ingress system. The NetBird management endpoint
will be exposed through Pangolin manually after deployment.

## Scope

This plan includes:

- The current combined NetBird server on `aether`.
- NetBird's embedded management, signal, relay, STUN, and identity provider.
- The NetBird dashboard as a management tool for the VPN mesh.
- NetBird clients on `aether`, `andromeda`, `meridian`, `zenith`, and
  `hyperion`.
- Local NetBird authentication for bootstrap and recovery.
- Setup-key enrollment after the server is running.
- Side-by-side validation with Tailscale.

This plan does not include:

- `pkgs.netbird-proxy` or `netbird-proxy.service`.
- NetBird's beta application reverse-proxy feature.
- A new host-level Traefik service.
- TLS passthrough or `*.proxy.mgrlab.dk` DNS.
- Replacing Pangolin, Gerbil, or either Newt agent.
- Exposing Pocket ID, Jellyfin, or other applications through NetBird.
- Advertising the K3s service network through NetBird.
- Removing or disabling Tailscale.

## Architecture

```text
Internet
   |
   v
Existing Pangolin ingress
   |
   | manually configured NetBird resource
   v
Aether Nginx gateway :8080
   |-- dashboard files
   |-- HTTP and WebSocket paths --> 127.0.0.1:8081
   `-- gRPC paths              --> 127.0.0.1:8081 using h2c

Internet ---------------- UDP 3478 ----------------> embedded NetBird STUN

NetBird peers <========== direct WireGuard or relay ==========> NetBird peers
```

Pangolin remains responsible for public HTTPS. Nginx is only the local
single-port gateway that combines the static dashboard and the combined
server's path-based protocols. No host-level process added by this plan should
listen on public TCP 80 or 443.

UDP 3478 is different: it is STUN traffic and cannot pass through an HTTP
reverse proxy. It must reach `aether` directly.

## Decisions

- Define independent `netbird-client` and `netbird-server` NixOS modules in one
  dendritic file.
- Import both modules explicitly on `aether`; the server module must not import
  the client module.
- Use `pkgs.netbird-combined` rather than the legacy split
  `services.netbird.server` stack.
- Implement the combined server as a custom hardened systemd service, following
  the useful server-service pattern from change `kxl` but omitting all proxy
  and Traefik code.
- Use upstream `services.netbird.clients` for every peer.
- Use UDP 51821 for the NetBird clients so Aether does not conflict with
  Gerbil's existing UDP 51820 binding.
- Keep all clients in routing mode `"client"`. Do not enable forwarding or
  advertise networks during this trial.
- Keep the server configuration explicit and close to NetBird's example YAML.
  Do not create a general-purpose custom server option hierarchy yet.
- Keep local NetBird authentication enabled. Pocket ID integration can be
  evaluated later without blocking mesh validation.
- Keep Pangolin, Vaultwarden, both Newt agents, existing DNS, and Tailscale
  unchanged.

## Baseline At Change `zw`

The following hosts already import `self.nixosModules.tailscale`:

- `hosts/aether/default.nix`
- `hosts/andromeda/default.nix`
- `hosts/meridian/default.nix`
- `hosts/zenith/default.nix`
- `hosts/hyperion/default.nix`

The shared module is `dendritic-modules/services/tailscale.nix`.

At `zw`, the ingress-related imports are active and must remain active:

- `./pangolin` and `./vaultwarden.nix` in
  `hosts/aether/containers/default.nix`.
- `./newt.nix` in `hosts/andromeda/containers/default.nix`.
- `./newt.nix` in `k8s/default.nix`.

No NetBird module, secrets, host imports, routing overrides, or proxy wildcard
DNS changes from `kxl` should be assumed to exist.

## Repository Changes

### Dendritic module

Add `dendritic-modules/services/netbird.nix` with exactly two exported NixOS
modules:

```nix
{ self, ... }:
{
  flake.nixosModules.netbird-client = { ... }: {
    # Upstream NetBird client configuration.
  };

  flake.nixosModules.netbird-server = { ... }: {
    # Combined server, dashboard, and local Nginx gateway.
  };
}
```

Do not put `netbird-proxy`, Traefik, Pangolin, DNS, or host-specific imports in
this file.

### Host imports

Add `self.nixosModules.netbird-client` next to the existing Tailscale module in
all five host entry points.

Add the server module explicitly on Aether:

```nix
modules = [
  self.nixosModules.tailscale
  self.nixosModules.netbird-client
  self.nixosModules.netbird-server
  # Existing modules...
];
```

Do not remove, replace, or override `self.nixosModules.tailscale`.

## Combined Server

Create `netbird-server.service` around `pkgs.netbird-combined`, whose executable
is `netbird-server`.

Use a generated YAML configuration with these settings:

- `server.listenAddress = "127.0.0.1:8081"`.
- `server.exposedAddress = "https://netbird.mgrlab.dk:443"`.
- Embedded signal and relay services.
- Embedded STUN on UDP 3478.
- Metrics on port 9090 without opening that port in the firewall.
- Health checks on `127.0.0.1:9000`.
- `server.dataDir = "/var/lib/netbird"`.
- SQLite management, activity, and embedded IdP stores.
- Embedded IdP issuer `https://netbird.mgrlab.dk/oauth2`.
- Dashboard redirects at `/nb-auth` and `/nb-silent-auth`.
- CLI redirect `http://localhost:53000/`.
- Local authentication enabled.
- Anonymous metrics disabled.

Persist `/var/lib/netbird` with `StateDirectory`. Run the service as a dedicated
`netbird-server` system user with restart behavior and systemd hardening that
still permits normal network access and UDP STUN operation.

Render the final YAML with a SOPS template at runtime. Secret values must not
enter generated Nix store paths.

Open only these NetBird-related ports in the NixOS firewall:

- UDP 3478 for public STUN.
- UDP 51821 from the independently imported NetBird client module.

Do not open TCP 8080, 8081, 9000, or 9090 publicly.

## Dashboard And Local Gateway

Use `services.netbird.server.dashboard` only to generate the configured static
dashboard. Do not enable the legacy split server stack.

Configure the dashboard with:

- Management API and gRPC endpoint `https://netbird.mgrlab.dk`.
- Authority `https://netbird.mgrlab.dk/oauth2`.
- Audience and client ID `netbird-dashboard`.
- Scopes `openid profile email groups`.
- Redirect URI `/nb-auth`.
- Silent redirect URI `/nb-silent-auth`.
- Access-token authentication.

Use Nginx on TCP 8080 as the single internal target for Pangolin. It must:

- Serve the generated dashboard as the catch-all route.
- Forward `/api` and `/oauth2` to `127.0.0.1:8081` over HTTP.
- Forward `/relay` and `/ws-proxy/` to `127.0.0.1:8081` with WebSocket support
  and long read timeouts.
- Forward `/signalexchange.SignalExchange/` and
  `/management.ManagementService/` to `127.0.0.1:8081` using gRPC/h2c with long
  read and send timeouts.
- Exclude `/management.ProxyService/` because this plan does not deploy the
  NetBird application proxy.

Bind the Nginx gateway so the existing Pangolin container stack can reach it.
Prefer a specific host or bridge address if Pangolin provides a stable one;
otherwise use `0.0.0.0:8080`. Do not add TCP 8080 to the global allowed-port
list. If the host firewall blocks the Pangolin connection, allow TCP 8080 only
on the actual Pangolin Podman bridge interface.

## Pangolin Manual Configuration

Do not add or change Pangolin resources in Nix as part of this plan.

After deploying Aether, manually configure Pangolin to publish
`netbird.mgrlab.dk` and target Aether's Nginx gateway on TCP 8080. Confirm that
the chosen Pangolin resource mode preserves:

- WebSocket upgrades for `/relay` and `/ws-proxy/`.
- Long-lived connections.
- Native gRPC/HTTP2 requests for Signal and Management.
- The original HTTPS scheme in forwarded headers.

If Pangolin cannot preserve the required gRPC and WebSocket behavior, stop the
rollout and keep using Tailscale. Do not add a second Traefik implementation as
an unplanned workaround.

The existing `*.mgrlab.dk` DNS record already covers `netbird.mgrlab.dk`; this
plan does not add DNS records.

## Client Module

Use the upstream multi-client interface:

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

Do not enable setup-key login in the first deployment because the setup key
cannot exist before the management server is running.

Do not configure NetBird networks, exit nodes, routing peers, or K3s routes in
this plan. Test peer-to-peer connectivity by NetBird IP first so coexistence
with Tailscale DNS can be evaluated separately.

## Secrets

Add these Aether-only secrets to
`hosts/aether/secrets/secrets.sops.yaml` and declare them in
`hosts/aether/secrets/default.nix`:

- `NETBIRD_AUTH_SECRET` for relay authentication.
- `NETBIRD_STORE_ENCRYPTION_KEY`, containing a base64-encoded 32-byte key.
- `NETBIRD_IDP_SESSION_COOKIE_ENCRYPTION_KEY`, containing a valid 16, 24, or
  32-byte cookie encryption key.

Generate every value with a cryptographically secure tool. Do not use example
values or place plaintext secrets in Nix expressions.

After the server is running, create a reusable setup key in NetBird and add
`NETBIRD_SETUP_KEY` to the shared encrypted SOPS file at
`dendritic-modules/secrets/secrets.yaml`. Ensure it is encrypted for every host
importing the NetBird client.

Then enable automated client enrollment:

```nix
services.netbird.clients.mgrlab.login = {
  enable = true;
  setupKeyFile = config.sops.secrets.NETBIRD_SETUP_KEY.path;
  systemdDependencies = [ "sops-install-secrets.service" ];
};
```

## Files That Must Not Change

This implementation must not alter these files for functional reasons:

- `hosts/aether/containers/default.nix`
- `hosts/andromeda/containers/default.nix`
- `k8s/default.nix`
- `infra/cloudflare-dns.nix`
- `dendritic-modules/services/tailscale.nix`

In particular, retain Pangolin, Gerbil, Vaultwarden, both Newt agents, and all
Tailscale imports and state.

## Bootstrap Sequence

### Phase 1: Server

1. Add the independent server and client modules.
2. Add the three Aether server secrets.
3. Import the server on Aether and the client on all five hosts, leaving client
   login automation disabled.
4. Format and dry-build every affected host.
5. Deploy Aether through the existing Tailscale connection.
6. Confirm `netbird-server.service` and Nginx are healthy locally.
7. Confirm UDP 3478 reaches Aether directly.
8. Manually expose the Nginx gateway through Pangolin.
9. Verify the public OIDC discovery endpoint and dashboard.
10. Create the initial local owner account.

### Phase 2: Peers

1. Create a reusable NetBird setup key.
2. Add the setup key to shared SOPS and enable automated login.
3. Deploy Aether first and confirm its NetBird client connects.
4. Deploy Andromeda and confirm Aether-to-Andromeda communication by NetBird IP.
5. Deploy Meridian, Zenith, and Hyperion one at a time.
6. Confirm all five peers appear in the dashboard and can communicate according
   to the default policy.
7. Confirm Tailscale still works on every deployed host.

Do not remove Tailscale after Phase 2. Its eventual removal requires a separate
decision and plan after an extended validation period.

## Build Verification

Before writing Nix code, re-check the package and option names with the NixOS
MCP server against unstable and the repository's locked nixpkgs revision.

Format changed Nix files with `nixfmt`.

Stage changes before evaluating the flake:

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

## Runtime Verification

Verify on Aether:

- `netbird-server.service` starts successfully.
- `/var/lib/netbird` survives a service restart.
- The server listens on loopback TCP 8081.
- The health endpoint listens on loopback TCP 9000.
- Nginx provides the combined local gateway on TCP 8080.
- TCP 8080, 8081, 9000, and 9090 are not publicly reachable.
- UDP 3478 is publicly reachable for STUN.
- Pangolin still owns the existing public ingress ports.
- Pangolin and Vaultwarden remain healthy.
- Both Newt agents remain configured.
- Tailscale remains connected.

Verify through `https://netbird.mgrlab.dk`:

- `/oauth2/.well-known/openid-configuration` returns valid JSON.
- The dashboard loads and local login succeeds.
- Management and Signal gRPC connections remain open.
- Relay WebSocket connections remain available.

Verify on every peer:

- `netbird-mgrlab.service` is active.
- `netbird-mgrlab status` reports the self-hosted management URL.
- The `nb-mgrlab` interface exists.
- Peer-to-peer traffic works by NetBird IP.
- Direct connections are used where NAT permits.
- Relay fallback works where direct connectivity is unavailable.
- Existing Tailscale addresses remain reachable.

## Rollback

If the NetBird server or clients fail:

1. Access Aether over Tailscale or the provider console.
2. Remove the manual Pangolin NetBird resource.
3. Remove the NetBird module imports from the affected hosts.
4. Rebuild the affected hosts.
5. Leave all NetBird state and encrypted secrets in place until the failure has
   been understood.

No Pangolin, Newt, Vaultwarden, DNS, or Tailscale restoration should be needed
because this plan never removes or disables them.

## Follow-Up

After the mesh has been stable for an agreed period, create separate plans for
any of the following:

- Removing Tailscale.
- Advertising private networks or K3s resources through NetBird.
- Connecting Pocket ID to the embedded identity provider.
- Replacing Pangolin with NetBird Proxy.
- Extracting a reusable combined-server NixOS option module.

After implementation, evaluate whether the custom combined-server systemd
pattern needs documentation in `AGENTS.md`. Merely adding the two dendritic
module exports does not require an update.
