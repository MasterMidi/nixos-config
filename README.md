<div align="center">
<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake-colours.svg" width="96px" height="96px" />

[![](https://readme-typing-svg.demolab.com/?font=JetBrains+Mono&size=32&duration=3000&pause=1000&color=EBDBB2&center=true&vCenter=true&random=false&width=435&lines=My+NixOS+config)](https://git.io/typing-svg)

<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px" /> <br>

<!-- spacer -->
<p></p>
<a href="https://github.com/MasterMidi/nixos-config/issues">
<img src="https://img.shields.io/github/issues/MasterMidi/nixos-config?color=d8a657&labelColor=32302f&style=for-the-badge">
</a>
<a href="https://github.com/MasterMidi/nixos-config/stargazers">
<img src="https://img.shields.io/github/stars/MasterMidi/nixos-config?color=d3869b&labelColor=32302f&style=for-the-badge">
</a>
<a href="https://github.com/MasterMidi/nixos-config/">
<img src="https://img.shields.io/github/repo-size/MasterMidi/nixos-config?color=ea999c&labelColor=32302f&style=for-the-badge">
</a>
<a href="https://github.com/MasterMidi/nixos-config/blob/main/LICENSE">
<img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=GPL-3&logoColor=d3869b&colorA=313244&colorB=cba6f7"/>
</a>
<a href="https://nixos.org">
<img src="https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=32302f&logo=NixOS&logoColor=white&color=7daea3">
</a>
<a href="https://nixos.org">
<img src="https://img.shields.io/github/last-commit/shvedes/dotfiles?style=for-the-badge&color=d8a657&labelColor=32302f">
</a>
<br>
</div>

## 📋 Overview

This repository contains my personal NixOS configurations for multiple machines, managed using Nix flakes. The configuration is structured to support both desktop and server systems with shared modules for common functionality.

### 🖥️ Machines

#### Desktops
- **jason** - Desktop workstation (x86_64-linux)
- **daniel** - Desktop workstation (x86_64-linux)

#### Servers
- **andromeda** - Server (x86_64-linux)
- **nova** - Server with declarative disk configuration (x86_64-linux)
- **pisces** - Raspberry Pi server (aarch64-linux, commented out)

All configurations use:
- **NixOS unstable** channel
- **Home Manager** for user environment management
- **Flake-based** configuration for reproducibility
- **Secret management** with sops-nix

## 🚀 Getting Started

### Prerequisites

- NixOS installed on your system
- Nix flakes enabled in your configuration
- Git for cloning the repository

### Initial Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/MasterMidi/nixos-config.git
   cd nixos-config
   ```

2. **Enter the development shell (optional but recommended):**
   ```sh
   nix develop
   # or if you have direnv installed:
   direnv allow
   ```

### Building a Configuration

To build a specific machine configuration:

```sh
# Build a configuration
nixos-rebuild build --flake .#<machine-name>

# Examples:
nixos-rebuild build --flake .#jason
nixos-rebuild build --flake .#daniel
nixos-rebuild build --flake .#nova
```

### Applying a Configuration

To switch to a new configuration:

```sh
# Switch to new configuration
sudo nixos-rebuild switch --flake .#<machine-name>

# Example:
sudo nixos-rebuild switch --flake .#jason
```

### Building SD Card Images (Raspberry Pi)

To build SD card images for Raspberry Pi systems:

```sh
nom build .#images.pisces
```

### Deployment to Remote Servers

This configuration supports remote deployment using lollypops:

```sh
# Deploy to a remote server
nix run .#deploy -- <machine-name>

# Or using the development shell command:
dply <machine-name>
```

## 📁 Repository Structure

```sh
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Flake lock file
├── shell.nix              # Development shell
├── machines/              # Machine-specific configurations
│   ├── desktops/          # Desktop configurations
│   │   ├── jason/         # Jason desktop config
│   │   ├── daniel/        # Daniel desktop config
│   │   └── shared/        # Shared desktop modules
│   ├── servers/           # Server configurations
│   │   ├── andromeda/     # Andromeda server config
│   │   ├── nova/          # Nova server config
│   │   └── pisces/        # Pisces Raspberry Pi config
│   └── shared/            # Shared modules for all machines
│       ├── core/          # Core system configuration
│       └── avahi.nix      # Network discovery
├── modules/               # Custom NixOS modules
├── overlays/              # Package overlays
├── pkgs/                  # Custom packages
├── secrets/               # Secret management (sops)
└── scripts/               # Utility scripts
```

## 🛠️ Development Tools

The development shell includes various tools for working with NixOS configurations:

- **nixpkgs-fmt** - Nix code formatter
- **statix** - Linting and anti-pattern detection
- **nix-output-monitor (nom)** - Better build output
- **nix-tree** - Visualize nix store
- **deploy-rs** - Deployment tool
- **sops** - Secret management
- **nixos-generators** - Generate various system images

### Available Commands

When in the development shell:

```sh
# Update flake inputs
nix-update

# Deploy to remote server
dply <machine-name>

# Evaluate a configuration
evl <machine-name>

# Update sops secrets
usops
```

## 🔐 Secret Management

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix). The secrets are encrypted and stored in the `secrets/` directory.

## 🎨 Features

- **Home Manager** integration for user environment
- **Declarative disk configuration** with disko (nova)
- **Hardware-specific optimizations** using nixos-hardware and nixos-facter
- **Custom modules** for development environments (Rust, .NET, Android)
- **Theming** with nix-colors and custom Firefox/Thunderbird themes
- **Gaming support** via nix-gaming
- **Container orchestration** with custom compose module
- **Network discovery** with Avahi

## 📝 License

This project is licensed under GPL-3 - see the [LICENSE](LICENSE) file for details.

---

*More names for future machines: https://www.reddit.com/r/namenerds/comments/1e4ot95/space_themed_names/*
