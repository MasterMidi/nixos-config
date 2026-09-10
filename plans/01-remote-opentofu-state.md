# Remote OpenTofu State

## Status

Proposed.

## Goal

Move the existing Cloudflare state out of the local, git-ignored
`infra/.terranix/` directory and establish a remote backend for every future
Terranix configuration.

The backend must provide:

- Encryption at rest and in transit.
- State locking.
- Object versioning and recovery.
- Credentials restricted to the state bucket.
- A separate state object for each Terranix configuration.

## Non-Goals

The remote backend is OpenTofu's persistence and coordination layer, not a
general configuration interface for NixOS. Pure Nix evaluation must not fetch
the state, require backend credentials, invoke `tofu output`, or depend on a
generated Terranix workdir.

Stable values declared by the repository, such as host names, architectures,
deployment DNS names, and provider selections, belong in the top-level
`flake.inventory` described by
[the infrastructure deployment bridge](./03-infrastructure-deployment-bridge.md).
Provider-generated values, such as resource IDs and allocated public IP
addresses, remain in OpenTofu state and may be exposed through a deliberately
small set of OpenTofu outputs for other OpenTofu configurations or runtime
bootstrap tools.

## Recommended Backend

Use a small AWS S3 bucket dedicated to OpenTofu state. Enable bucket
versioning, public-access blocking, server-side encryption, and OpenTofu's
native S3 lock file.

Expected object layout:

```text
mgrlab-opentofu-state/
├── cloudflare-dns/terraform.tfstate
├── hcloud-aether/terraform.tfstate
└── future-hosts/...
```

Hetzner Object Storage is not the first choice for this backend. Hetzner
documents that conditional PUT and DELETE operations are unsupported on
versioned buckets, while OpenTofu's native S3 locking uses conditional writes.
Using Hetzner would therefore require accepting weaker recovery or locking,
or proving a different locking mechanism reliable before migration.

The backend bucket is foundational infrastructure and should initially be
created outside the state that it stores. It can be documented declaratively,
but the bucket must not be destroyable by an ordinary infrastructure apply.

## Proposed Repository Changes

```text
infra/
├── default.nix
├── backend.nix
├── cloudflare-dns.nix
├── README.md
└── secrets/
    └── secrets.sops.yaml
```

`infra/backend.nix` should be a small reusable module parameterized by the
state name:

```nix
{ stateName }:
{
  terraform.backend.s3 = {
    bucket = "mgrlab-opentofu-state";
    key = "${stateName}/terraform.tfstate";
    region = "<backend-region>";
    encrypt = true;
    use_lockfile = true;
  };
}
```

Each Terranix configuration should include its own instance:

```nix
modules = [
  (import ./backend.nix { stateName = "cloudflare-dns"; })
  ./cloudflare-dns.nix
];
```

Backend credentials must be decrypted by the wrapper and exported as
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. They must not be embedded in
the backend module, generated Terraform JSON, shell history, or state.

## Implementation Phases

### 1. Provision The Backend

- [ ] Select the S3 account and region.
- [ ] Create a bucket used only for OpenTofu state.
- [ ] Block all public access.
- [ ] Enable object versioning.
- [ ] Enable server-side encryption.
- [ ] Create credentials limited to listing the bucket and reading, writing,
      deleting, and locking the required state prefixes.
- [ ] Configure lifecycle cleanup for old lock-file versions without removing
      useful state history prematurely.
- [ ] Record the recovery procedure in `infra/README.md`.

### 2. Add Backend Credentials

- [ ] Add the backend access key ID and secret access key to
      `infra/secrets/secrets.sops.yaml`.
- [ ] Extend the Terranix wrapper to decrypt and export the credentials.
- [ ] Confirm the wrapper does not print decrypted values.
- [ ] Keep Cloudflare and backend credentials independently scoped.

### 3. Add Shared Backend Configuration

- [ ] Add `infra/backend.nix`.
- [ ] Include it in `cloudflare-dns` using the key
      `cloudflare-dns/terraform.tfstate`.
- [ ] Add a dedicated migration command or app that invokes
      `tofu init -migrate-state`; Terranix's normal generated `init` app does
      not include the migration flag.
- [ ] Keep normal `plan` and `apply` commands unchanged after migration.

### 4. Migrate Cloudflare State

- [ ] Stop all concurrent OpenTofu operations.
- [ ] Make an encrypted offline copy of the current local state and its backup.
- [ ] Generate the new configuration containing the S3 backend.
- [ ] Run `tofu init -migrate-state` from the Cloudflare Terranix workdir.
- [ ] Confirm the migration prompt identifies the expected source and target.
- [ ] Verify that the remote state object and lock object can be created.
- [ ] Run `tofu plan` and require a no-change result.
- [ ] Retain the encrypted offline copy until several successful plans and
      applies have completed.

### 5. Verify Recovery And Locking

- [ ] Start one operation that holds the state lock.
- [ ] Confirm a second operation cannot acquire the same state.
- [ ] Confirm different state keys can be used concurrently.
- [ ] Test downloading a previous state version without replacing the active
      state.
- [ ] Document force-unlock and state-version restoration procedures.

## Safety Rules

- Never commit a state file, plan file, backend credential, or decrypted SOPS
  output.
- Never use `-lock=false` during a normal plan or apply.
- Never use `-force-copy` for migration without first inspecting the source and
  destination.
- Treat state as sensitive even when no resource deliberately stores secrets.
- Give each infrastructure area its own state to limit blast radius.
- Back up state before changing provider versions, backend settings, or import
  blocks.

## Validation

```sh
nix run .#cloudflare-dns.plan
nix develop .#cloudflare-dns
tofu state list
```

The final plan must show no Cloudflare DNS replacement or deletion caused by
the backend migration.

## Completion Criteria

- Cloudflare state is stored remotely under its own key.
- Versioning, encryption, and locking have been tested.
- No active state remains dependent on one workstation.
- Backend credentials are SOPS-encrypted and least-privileged.
- The migration and recovery procedures are documented.
- New Terranix configurations can reuse `infra/backend.nix` with a distinct
  state name.
- NixOS evaluation remains independent of the backend, its credentials, and
  its current contents.
