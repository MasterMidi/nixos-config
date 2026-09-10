# Hetzner Infrastructure For Aether

## Status

Proposed. Depends on [remote OpenTofu state](./01-remote-opentofu-state.md).

## Goal

Add a separate `hcloud-aether` Terranix configuration that initially manages
the cloud resources surrounding the existing `aether` VPS without taking
ownership of the server lifecycle.

After the perimeter configuration is stable, optionally import the server,
primary IPs, and related resources so the VPS can be recreated deliberately.

## Ownership Stages

### Stage A: Observe The Existing Server

Use an `hcloud_server` data source to discover `aether` by name. A data source
allows Terranix to reference the server ID and addresses but cannot replace or
delete it.

Manage only:

- A Hetzner Cloud firewall.
- The firewall attachment to `aether`.
- Reverse DNS where appropriate.
- Non-sensitive outputs such as the server ID and public addresses.

This is the recommended initial scope.

### Stage B: Adopt Independent Resources

After stable no-change plans, import independently managed resources such as:

- Primary IPv4 and IPv6 allocations.
- Existing SSH public keys.
- Existing firewalls.
- Reverse DNS records.
- Private networks or volumes, if they exist.

Each resource should be imported and verified separately.

### Stage C: Adopt The Server

Only after the first two stages are stable, describe and import the existing
`hcloud_server`. Enable Hetzner delete and rebuild protection and OpenTofu
`prevent_destroy` before considering normal lifecycle management.

Do not proceed if the first post-import plan proposes replacing `aether`.

## Proposed Repository Changes

```text
infra/
├── default.nix
├── backend.nix
├── cloudflare-dns.nix
├── hcloud-aether.nix
├── inventory.nix
├── README.md
└── secrets/
    └── secrets.sops.yaml
```

Add the Terranix configuration in `infra/default.nix`:

```nix
terranix.terranixConfigurations.hcloud-aether = {
  modules = [
    (import ./backend.nix { stateName = "hcloud-aether"; })
    ./hcloud-aether.nix
  ];

  workdir = "infra/.terranix/hcloud-aether";

  terraformWrapper = {
    package = pkgs.opentofu.withPlugins (plugins: [
      plugins.hetznercloud_hcloud
    ]);

    extraRuntimeInputs = [ pkgs.sops ];

    prefixText = ''
      # Decrypt and export HCLOUD_TOKEN and backend credentials.
    '';
  };
};
```

The provider package is `terraform-providers.hetznercloud_hcloud`. The version
available in nixpkgs unstable when this plan was written was 1.68.0.

The first version of `infra/hcloud-aether.nix` should use a data source:

```nix
{
  data.hcloud_server.aether.name = "aether";

  resource.hcloud_firewall.aether = {
    name = "aether";
    # Rules are added after the listener inventory is complete.
  };

  resource.hcloud_firewall_attachment.aether = {
    firewall_id = "\${hcloud_firewall.aether.id}";
    server_ids = [ "\${data.hcloud_server.aether.id}" ];
  };

  output.aether_ipv4.value =
    "\${data.hcloud_server.aether.ipv4_address}";
}
```

## Implementation Phases

### 1. Inventory Hetzner Resources

- [ ] Create a read/write Hetzner Cloud API token scoped to the project that
      contains `aether`.
- [ ] Add the token to `infra/secrets/secrets.sops.yaml`.
- [ ] Record the server ID, location, type, labels, image state, public IPs,
      backup setting, protection settings, attached firewalls, volumes,
      networks, and SSH keys.
- [ ] Record existing reverse DNS entries.
- [ ] Inventory active TCP and UDP listeners on `aether`.
- [ ] Compare active listeners with ports published by Pangolin and the NixOS
      firewall.

No resource should be imported until the inventory is complete.

### 2. Add The Provider And Read-Only Lookup

- [ ] Add the packaged Hetzner provider to the OpenTofu wrapper.
- [ ] Pin `terraform.required_providers.hcloud` to the packaged version.
- [ ] Decrypt `HCLOUD_TOKEN` in the wrapper without printing it.
- [ ] Add the remote backend key `hcloud-aether/terraform.tfstate`.
- [ ] Add `data.hcloud_server.aether`.
- [ ] Expose server ID, IPv4, IPv6, location, and status as non-sensitive
      outputs.
- [ ] Run a plan and confirm that it creates no resources.

### 3. Create The Cloud Firewall

Likely public requirements based on the current configuration are:

| Protocol | Port | Purpose |
| --- | ---: | --- |
| TCP | 80 | HTTP and HTTPS redirection |
| TCP | 443 | HTTPS |
| UDP | 443 | HTTP/3, if retained |
| UDP | 51820 | Pangolin/Gerbil tunnel traffic |
| ICMP | any | Network diagnostics |
| TCP | 22 | SSH from explicitly approved source ranges |

These are assumptions to verify, not rules to apply blindly.

- [ ] Restrict SSH to a trusted source range or private overlay route where
      operationally possible.
- [ ] Do not expose mail ports merely because the Pangolin container publishes
      them; the Stalwart service is disabled and the domain currently uses
      Proton Mail.
- [ ] Decide whether outbound filtering is needed. Start with inbound rules
      only unless there is a concrete egress policy.
- [ ] Create the firewall without attaching it.
- [ ] Compare its rules with the host-level NixOS firewall.
- [ ] Attach it during a maintenance window with a second access path
      available.
- [ ] Verify SSH, HTTPS, HTTP/3, and tunnel connectivity before ending the
      maintenance window.

The Hetzner firewall supplements the NixOS firewall; it does not replace it.

### 4. Manage Reverse DNS

- [ ] Choose an explicit host name such as `aether.mgrlab.dk`.
- [ ] Ensure the forward DNS record points to the correct public address.
- [ ] Manage the matching PTR using `hcloud_rdns`.
- [ ] Verify forward-confirmed reverse DNS.
- [ ] Revisit the PTR if `aether` later becomes an outbound mail server.

### 5. Adopt Primary IPs And Supporting Resources

- [ ] Add one resource definition at a time.
- [ ] Add an import block using the resource's current Hetzner ID.
- [ ] Set `auto_delete = false` for primary IPs unless deletion with the server
      is explicitly desired.
- [ ] Enable delete protection for stable addresses where supported.
- [ ] Apply the import and require a no-change follow-up plan.
- [ ] Keep permanent import blocks only if they remain useful documentation and
      are inert after adoption.

### 6. Optionally Adopt The Server

- [ ] Reproduce the observed server type, location, labels, network, backup,
      protection, and IP configuration in `hcloud_server.aether`.
- [ ] Set `delete_protection = true` and `rebuild_protection = true`.
- [ ] Add `lifecycle.prevent_destroy = true`.
- [ ] Account for creation-only attributes. In particular, changing the
      `ssh_keys` list can cause replacement and may need an explicit
      `ignore_changes` entry for an adopted server.
- [ ] Import the server ID.
- [ ] Reject any plan that destroys, replaces, rebuilds, or detaches the root
      disk or stable public addresses.
- [ ] Document the deliberate procedure required to permit future replacement.

## Safety Rules

- Keep `hcloud-aether` state separate from Cloudflare state.
- Never use provisioners to configure the running OS; NixOS owns that layer.
- Never put private SSH keys, API tokens, generated passwords, or decrypted
  SOPS values in OpenTofu configuration or outputs.
- Do not make the first firewall attachment without an alternate recovery path
  through the Hetzner console.
- Do not add a private network until there is a second Hetzner resource that
  benefits from it.
- Do not import the VPS merely for completeness; adopt it only when deliberate
  lifecycle ownership is valuable.

## Validation

```sh
nix run .#hcloud-aether.plan
nix develop .#hcloud-aether
tofu state list
tofu output
```

Validation after firewall attachment must include:

- SSH or deploy-rs connectivity.
- HTTPS access through Pangolin.
- WireGuard tunnel establishment.
- DNS resolution and reverse DNS.
- A second OpenTofu plan with no unexpected changes.

## Completion Criteria

- `hcloud-aether` uses its own remote state.
- The Hetzner API token is SOPS-encrypted and never printed.
- The cloud firewall is minimal, documented, attached, and tested.
- The existing server can be referenced through stable outputs.
- Reverse DNS is declarative.
- Any imported resource has a no-change follow-up plan.
- The server remains externally managed unless Stage C is explicitly approved.
