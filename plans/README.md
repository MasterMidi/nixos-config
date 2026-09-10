# Infrastructure Plans

These plans describe the next stages of the Terranix setup. They are ordered
because later plans depend on the state and outputs established by earlier
ones.

1. [Remote OpenTofu state](./01-remote-opentofu-state.md)
2. [Hetzner infrastructure for aether](./02-hetzner-aether-infrastructure.md)
3. [Infrastructure and deployment bridge](./03-infrastructure-deployment-bridge.md)

The intended ownership boundaries are:

- Terranix provisions resources exposed through external APIs.
- NixOS configures machines after they exist.
- EasyKubenix manages resources inside the Kubernetes cluster.
- deploy-rs activates subsequent NixOS generations.
- SOPS stores credentials; OpenTofu state must not be treated as a secret
  store.
