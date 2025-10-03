# NixOS Configuration

This repository contains my NixOS configuration for multiple machines using Nix flakes.

## 📦 Machines

- **jason** - Desktop (x86_64-linux)
- **daniel** - Desktop (x86_64-linux)
- **andromeda** - Server (x86_64-linux)
- **nova** - Server (x86_64-linux)

## 🚀 Deployment

This configuration uses [deploy-rs](https://github.com/serokell/deploy-rs) for remote deployments.

### Prerequisites

- SSH access to the target machine with root privileges
- The target machine's SSH public key must be in your `~/.ssh/known_hosts`
- Your SSH public key must be in the target machine's `/root/.ssh/authorized_keys`

### Deploying to a Remote Machine

To deploy a configuration to a remote machine:

```bash
# Deploy to a specific machine
dply <hostname>

# Examples:
dply jason
dply daniel
dply andromeda
dply nova
```

The `dply` command is a shell alias that runs `deploy .#<hostname>`.

### How Deployment Works

1. **deploy-rs** builds the NixOS configuration locally on your machine
2. It copies the built system closure to the remote machine via SSH
3. The remote machine activates the new configuration
4. If activation fails, deploy-rs automatically rolls back to the previous configuration

### Manual Deployment

If you prefer not to use the `dply` shell command, you can deploy manually:

```bash
# Deploy to a specific node
deploy .#<hostname>

# Deploy to all nodes
deploy
```

### Deploy Configuration

The deploy-rs configuration is defined in `flake.nix` under the `deploy.nodes` attribute. Each node specifies:

- **hostname**: The SSH hostname or IP address
- **sshUser**: The SSH user (default: root)
- **profiles.system.user**: The user to activate the system as (default: root)
- **profiles.system.path**: The system closure to deploy

## 🏗️ Building

### Building SD Card Image (Raspberry Pi)

To build SD card images for Raspberry Pi systems:

```bash
nom build .#images.pisces
```

## 🛠️ Development

This repository uses a development shell with various NixOS tools. Enter the shell with:

```bash
# Using direnv (automatically loads with .envrc)
direnv allow

# Or manually
nix develop
```

### Available Commands

- `dply <hostname>` - Deploy to remote server
- `evl <hostname>` - Evaluate NixOS configuration
- `nix-update` - Update dependencies
- `usops` - Update all SOPS secrets with current keys

## 📁 Configuration Structure

```
.
├── flake.nix              # Main flake configuration
├── shell.nix              # Development shell
├── machines/              # Machine-specific configurations
│   ├── desktops/         # Desktop machines
│   │   ├── jason/
│   │   ├── daniel/
│   │   └── shared/       # Shared desktop config
│   ├── servers/          # Server machines
│   │   ├── andromeda/
│   │   ├── nova/
│   │   └── pisces/
│   └── shared/           # Shared configurations
│       └── core/         # Core system config
├── modules/              # NixOS modules
├── overlays/             # Nix package overlays
├── pkgs/                 # Custom packages
└── secrets/              # SOPS secrets
```

## 🔐 Secrets Management

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix). To update secrets:

```bash
usops
```

## 📝 License

GPL-3.0
