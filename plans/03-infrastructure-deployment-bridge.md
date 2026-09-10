# Infrastructure And Deployment Bridge

## Status

Proposed. Depends on:

- [Remote OpenTofu state](./01-remote-opentofu-state.md)
- [Hetzner infrastructure for aether](./02-hetzner-aether-infrastructure.md)

This plan also develops the host metadata idea already recorded in
`todo.md`.

## Goal

Create a clear handoff from Terranix-provisioned infrastructure to Cloudflare
DNS, NixOS installation, and deploy-rs without making pure Nix evaluation read
mutable OpenTofu state.

The intended dependency chain is:

```text
remote state
    ↓
hcloud-aether
    ↓
cloudflare-dns
    ↓
stable deployment hostname
    ↓
NixOS and deploy-rs
```

For future machines, add a one-time installation path:

```text
Terranix creates host
    ↓
runtime bootstrap app reads tofu output
    ↓
nixos-anywhere installs the host's flake configuration
    ↓
deploy-rs owns subsequent NixOS activations
```

## Design Rules

- Nix evaluation must not execute `tofu output`, access remote state, or depend
  on a Terranix workdir.
- Static desired metadata is shared through the top-level `flake.inventory`
  output.
- Provider-generated resource IDs and allocated IP addresses remain in
  OpenTofu state.
- DNS is the stable contract consumed by deploy-rs.
- Scripts may read OpenTofu outputs at runtime for bootstrap operations.
- OpenTofu provisions machines but does not configure their operating systems.
- deploy-rs updates installed machines but does not create cloud resources.

## Proposed Repository Changes

```text
infra/
├── default.nix
├── backend.nix
├── inventory.nix
├── cloudflare-dns.nix
├── hcloud-aether.nix
├── apps.nix
└── README.md
```

`infra/inventory.nix` contains only stable, non-secret metadata:

```nix
{
  domains.primary = "mgrlab.dk";

  hosts = {
    aether = {
      hostName = "aether";
      system = "x86_64-linux";
      deployHost = "aether.mgrlab.dk";

      infrastructure = {
        provider = "hcloud";
        serverName = "aether";
        stateName = "hcloud-aether";
      };
    };

    andromeda = {
      hostName = "andromeda";
      system = "x86_64-linux";
      deployHost = "andromeda";
      lanIPv4 = "192.168.1.139";
    };
  };
}
```

`infra/default.nix` imports this file once, exposes it as a custom top-level
flake output, and passes the same value to Terranix through `extraArgs`:

```nix
{ inputs, ... }:

let
  inventory = import ./inventory.nix;
in
{
  imports = [ inputs.terranix.flakeModule ];

  flake.inventory = inventory;

  perSystem =
    { pkgs, ... }:
    {
      terranix.terranixConfigurations.hcloud-aether = {
        extraArgs = { inherit inventory; };
        modules = [ ./hcloud-aether.nix ];
        workdir = "infra/.terranix/hcloud-aether";

        # OpenTofu wrapper configuration omitted.
      };
    };
}
```

Host flake modules consume the exported output rather than importing the file
again:

```nix
{
  inputs,
  self,
  ...
}:

let
  host = self.inventory.hosts.aether;
in
{
  flake.nixosConfigurations.aether = inputs.nixpkgs.lib.nixosSystem {
    system = host.system;
    specialArgs = {
      inherit inputs self;
      hostMetadata = host;
    };

    modules = [ ./configuration.nix ];
  };

  deploy.nodes.aether.hostname = host.deployHost;
}
```

Terranix modules receive the same value without accessing the recursive flake
output:

```nix
{ inventory, ... }:

let
  host = inventory.hosts.aether;
in
{
  data.hcloud_server.aether.name = host.infrastructure.serverName;
}
```

The inventory is the source of truth only for declared inputs. It may contain
manually assigned addresses, such as a static LAN address. It must not contain
API tokens, generated passwords, mutable provider IDs, or a public IP allocated
as a result of an OpenTofu apply. Such an address is an OpenTofu output even
when it is expected to remain stable.

Start with the plain central `inventory.nix` file. Add a typed custom
flake-parts inventory module only if host metadata later needs to be declared
across multiple modules and merged or validated centrally.

## Output Contract

`hcloud-aether` should expose a small, documented output contract:

```nix
output.aether.value = {
  id = "\${data.hcloud_server.aether.id}";
  ipv4 = "\${data.hcloud_server.aether.ipv4_address}";
  ipv6 = "\${data.hcloud_server.aether.ipv6_address}";
  deploy_hostname = host.deployHost;
};
```

Only outputs needed by another configuration or an operator should be added.
Marking an output sensitive only hides normal CLI display; it does not remove
the value from state. Secrets must therefore not be outputs.

## Implementation Phases

### 1. Introduce Shared Static Inventory

- [ ] Add `infra/inventory.nix` with the stable metadata for `aether`.
- [ ] Expose the imported value as the top-level `flake.inventory` output.
- [ ] Pass the inventory to `hcloud-aether` through Terranix `extraArgs`.
- [ ] Consume `self.inventory.hosts.aether` in
      `hosts/aether/default.nix` instead of importing the inventory again.
- [ ] Use the inventory for the NixOS system, host name, and deploy-rs
      deployment hostname where applicable.
- [ ] Keep architecture and host names in the inventory, but leave NixOS module
      lists in the host configuration.
- [ ] Document which fields are stable inputs and which values remain dynamic
      OpenTofu outputs.
- [ ] Verify `nix eval .#inventory.hosts.aether --json` works without network
      access or backend credentials.

### 2. Add An Explicit Deployment DNS Record

- [ ] Add `aether.mgrlab.dk`; do not rely only on `*.mgrlab.dk`.
- [ ] Initially point it at the existing stable address.
- [ ] Set `deploy.nodes.aether.hostname` to `aether.mgrlab.dk`.
- [ ] Verify deploy-rs resolves and reaches the host through the intended
      public or overlay path.
- [ ] Decide whether deployment should use public SSH, Tailscale DNS, or another
      private address before tightening the cloud firewall.

### 3. Connect HCloud Output To Cloudflare State

After the explicit record and remote states are stable, replace the duplicated
IP with an OpenTofu remote-state reference:

```text
hcloud-aether output aether_ipv4
    ↓
cloudflare-dns data.terraform_remote_state.hcloud_aether
    ↓
cloudflare_dns_record.aether
```

- [ ] Add `aether_ipv4` as a root output in `hcloud-aether`.
- [ ] Add a `terraform_remote_state` data source to `cloudflare-dns` using the
      same S3 backend and the read-only HCloud state key.
- [ ] Set the explicit DNS record content from that output.
- [ ] Give the Cloudflare state runner read-only access to the HCloud state and
      write access only to its own state.
- [ ] Apply `hcloud-aether` before planning `cloudflare-dns`.
- [ ] Verify that an unchanged IP produces no DNS update.

This creates an intentional dependency from Cloudflare to HCloud, but not from
HCloud back to Cloudflare.

The Cloudflare runner's read access to the HCloud state object exposes the
whole state object at the storage layer, even though
`terraform_remote_state` publishes only root outputs to the configuration.
Keep the output contract small, do not place secrets in state outputs, and use
a credential that can read only the required HCloud state key.

### 4. Add Ordered Operator Commands

Expose commands that make dependencies visible without hiding confirmation
steps:

```text
infra-plan-aether
├── plan hcloud-aether
├── plan cloudflare-dns
└── dry-build NixOS aether

infra-apply-aether
├── apply hcloud-aether
├── apply cloudflare-dns
└── print the deploy-rs command
```

- [ ] Add a plan command that stops at the first failure.
- [ ] Keep HCloud and Cloudflare apply confirmations visible.
- [ ] Do not automatically deploy NixOS merely because infrastructure was
      applied.
- [ ] Print `dply .#aether` as the next explicit action.
- [ ] Add non-interactive variants only when CI is introduced with appropriate
      approval controls.

### 5. Add A Future Host Bootstrap App

The existing `aether` installation does not need to be bootstrapped again.
This phase creates a reusable path for replacement or future Hetzner hosts.

- [ ] Generalize the HCloud module around host inventory only after a second
      host exists; avoid premature abstraction.
- [ ] Create the server with a temporary installation SSH public key and a
      firewall that permits the bootstrap connection.
- [ ] Read the new server IP from `tofu output` inside a runtime script.
- [ ] Run `nixos-anywhere --flake .#<host> root@<ip>` using the host's Disko
      configuration.
- [ ] Wait for the installed system to reboot and become reachable.
- [ ] Apply the stable DNS record.
- [ ] Switch deploy-rs to the stable host name.
- [ ] Remove temporary bootstrap access after the first successful deployment.

`nixos-anywhere` is the installation tool for this workflow. The version in
nixpkgs unstable when this plan was written was 1.13.0.

### 6. Document Replacement And Recovery

- [ ] Document how to restore the remote state before replacing a host.
- [ ] Document how to deliberately disable `prevent_destroy` and Hetzner
      protection for an approved replacement.
- [ ] Document how persistent data is restored independently of the root disk.
- [ ] Document DNS cutover and rollback.
- [ ] Document how to recover when Terranix succeeds but NixOS installation
      fails.
- [ ] Document how to recover when NixOS installation succeeds but DNS or
      deploy-rs fails.

## Routine Workflows

### Existing Aether

```sh
nix run .#hcloud-aether.plan
nix run .#cloudflare-dns.plan
git add -A
nixos-rebuild dry-build --flake .#aether
nix run .#hcloud-aether
nix run .#cloudflare-dns
dply .#aether
```

Infrastructure and NixOS changes should remain independently applicable. The
combined command exists to guide ordering, not to turn every change into one
unconditional transaction.

### Future Hetzner Host

```text
1. Apply the host's Terranix configuration.
2. Read its address from the Terranix wrapper at runtime.
3. Install NixOS with nixos-anywhere and Disko.
4. Apply DNS.
5. Verify the stable deployment hostname.
6. Activate subsequent configurations with deploy-rs.
```

## Failure Boundaries

| Failure | Expected recovery |
| --- | --- |
| HCloud plan is wrong | Stop before apply; DNS and NixOS remain unchanged. |
| HCloud apply fails | Repair HCloud state/resource; do not run DNS apply. |
| DNS apply fails | Server remains reachable by output IP. |
| NixOS bootstrap fails | Server remains in rescue/bootstrap state for retry. |
| deploy-rs fails | Use its rollback behavior or Hetzner console access. |
| State is lost or corrupt | Restore a versioned backend object before applying. |

## Safety Rules

- Never make Nix flake evaluation depend on network access or current OpenTofu
  state.
- Never write generated IPs or provider IDs back into tracked Nix files during
  a normal apply.
- Never make DNS the only recovery route before verifying direct IP or console
  access.
- Never automatically remove bootstrap SSH access until the installed system
  has passed a deploy-rs connectivity check.
- Never combine infrastructure destruction with an ordinary NixOS deployment.
- Preserve separate state and confirmation boundaries even when helper commands
  orchestrate several plans.

## Validation

- `nix eval .#deploy.nodes.aether.hostname` succeeds without backend
  credentials or network access.
- `nix eval .#inventory.hosts.aether --json` exposes the shared static host
  definition.
- `hcloud-aether` exposes only the documented outputs.
- `cloudflare-dns` reads the HCloud state without write permission to it.
- `aether.mgrlab.dk` resolves to the HCloud output address.
- deploy-rs reaches `aether` through the stable name.
- Re-running all plans after deployment produces no unexpected changes.

## Completion Criteria

- Stable host metadata has a single static source of truth exposed as
  `flake.inventory`.
- Dynamic infrastructure values remain in remote state.
- Cloudflare consumes the HCloud address through an explicit one-way
  dependency.
- deploy-rs uses a stable DNS contract rather than a mutable IP.
- Ordered plan and apply commands make dependencies clear.
- A documented runtime path exists for provisioning and installing a future
  Hetzner NixOS host.
