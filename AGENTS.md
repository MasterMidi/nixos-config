# AI Agent Instructions for NixOS Configuration Repository

> **Purpose**: This document provides comprehensive guidance for AI agents working on this flake-based NixOS configuration repository. It serves as the primary reference for understanding structure, conventions, and workflows.

## 🎯 Quick Start for AI Agents

When first starting work on this repository:

1. **Read this file completely** - Understand the structure and rules
2. **Check `.editorconfig`** - Follow formatting standards (tabs, size 2)
3. **Review `flake.nix`** - Understand the host configurations
4. **Use `nixfmt` (`pkgs.nixfmt`)** - For all Nix code formatting (`nixfmt-rfc-style` is now an alias for `pkgs.nixfmt`)
5. **Test with `nixos-rebuild dry-build`** - Before any changes
6. **Verify with NixOS MCP** - Always check package names and options via the MCP server (channel: `unstable`) before writing Nix code

## 🔒 Critical Rules (Never Break These)

1. **Formatting**: Use `pkgs.nixfmt` exclusively - never use other formatters (`nixfmt-rfc-style` is now an alias for `pkgs.nixfmt`)
2. **Indentation**: Use tabs (size 2) as defined in `.editorconfig`
3. **Testing**: Always run `git add -A && nixos-rebuild dry-build --flake .#<hostname>` before applying changes — `git add` is required because Nix flakes only evaluate git-tracked (committed or staged) files; new untracked files are silently ignored
4. **Secrets**: Never commit unencrypted secrets - use SOPS with age encryption
5. **Documentation**: Update relevant docs (this file, README.md) when making structural changes
6. **Self-review**: After completing any task, always evaluate whether AGENTS.md instructions need updating to reflect new patterns, deprecations, or conventions discovered
7. **Consistency**: Follow existing patterns in the codebase
8. **Verify packages and options with MCP**: Before using any package name or NixOS/Home Manager option, always verify it using the NixOS MCP server (see the section below). Never guess package or option names.

## 🔎 Using the NixOS MCP Server

**Always use the NixOS MCP server** before writing Nix code to verify package names, option paths, and Home Manager module availability. This prevents errors from renamed, removed, or misspelled attributes.

### nixpkgs channel

This repository tracks **nixpkgs unstable**. Always pass `channel: "unstable"` when querying the MCP server.

### Common queries

| Goal | MCP action |
|---|---|
| Verify a package name exists | `action: "info", query: "<name>", source: "nixos", type: "packages", channel: "unstable"` |
| Search for packages by keyword | `action: "search", query: "<keyword>", source: "nixos", type: "packages", channel: "unstable"` |
| Check Home Manager options for a program | `action: "search", query: "<program>", source: "home-manager", type: "options"` |
| Check NixOS module options | `action: "search", query: "<option prefix>", source: "nixos", type: "options", channel: "unstable"` |

### Rules

- **Always verify package names** before using them in `pkgs.<name>` or `environment.systemPackages`
- **Always check Home Manager options** before configuring `programs.<name>.*` — options change between releases
- **Prefer Home Manager modules** over raw `home.packages` when a `programs.<name>` module exists
- If a build returns a rename/alias warning for a package, look up the correct name with MCP before fixing it

## 📚 Technology Stack

This is a **production NixOS configuration** managing multiple physical and virtual machines:

- **NixOS Flakes** - Reproducible, declarative system configuration
- **Home Manager** - User environment and dotfiles management
- **SOPS-nix** - Secret management with age encryption
- **Disko** - Declarative disk partitioning (on some hosts)
- **nixos-facter** - Hardware detection and configuration generation
- **deploy-rs** - Remote deployment tooling
- **flake-parts** - Modular flake structure
- **Custom modules** - Reusable configuration abstractions

### Key Flake Inputs

- `nixpkgs` - NixOS unstable channel
- `home-manager` - User environment management
- `sops-nix` - Secrets encryption
- `disko` - Disk configuration
- `nixos-facter-modules` - Hardware detection
- `deploy-rs` - Remote deployment
- `nix-gaming` - Gaming-related packages/patches
- `rust-overlay` - Rust toolchain management

## 🏗️ Repository Architecture

### Directory Structure

```
/etc/nixos/
├── flake.nix              # Main flake entry point - defines all hosts
├── flake.lock             # Locked dependency versions
├── shell.nix              # Development shell configuration
├── .sops.yaml             # SOPS encryption key configuration
├── .editorconfig          # Code style enforcement
│
├── hosts/                 # Per-host configurations
│   ├── meridian/          # Laptop (x86_64-linux)
│   ├── zenith/            # Workstation (x86_64-linux)
│   ├── andromeda/         # NAS/Server (x86_64-linux)
│   ├── aether/            # Hetzner VPS (x86_64-linux)
│   ├── hyperion/          # WSL work laptop (x86_64-linux)
│   ├── voyager/           # Generic host
│   └── callisto/          # Raspberry Pi 5 (aarch64-linux)
│
├── modules/               # Custom NixOS modules
│   ├── nixos/             # System-level modules
│   │   ├── compose/       # OCI container compose module
│   │   ├── development/   # Dev environment modules
│   │   ├── refind/        # Boot manager config
│   │   └── ...
│   └── flakes/            # Flake-specific modules
│
├── pkgs/                  # Custom package definitions
│   ├── openthread-border-router/
│   ├── refind-minimal/
│   └── default.nix        # Package registry
│
├── secrets/               # SOPS-encrypted secrets (shared)
├── k8s/                   # Kubernetes manifests (easykubenix)
├── profiles/              # Reusable profile modules
├── scripts/               # Utility scripts
└── users/                 # User-specific configurations
```

### Host Configuration Structure

Each host typically follows this pattern:

```
hosts/<hostname>/
├── default.nix            # Main entry point (imports all modules)
├── configuration.nix      # NixOS system configuration
├── hardware.nix           # Hardware-specific settings
├── facter.json            # Hardware detection output
├── disko.nix              # Disk layout (if using disko)
├── system.nix             # System-level settings
├── user-interface.nix     # GUI/Desktop settings
├── power-management.nix   # Power settings
├── home-assistant.nix     # Service configs
└── secrets/               # Host-specific SOPS secrets
    └── secrets.sops.yaml
```

## 🎨 Naming Conventions

### Hostnames
- **Workstations/Laptops**: Astronomy/space themes (`meridian`, `zenith`, `voyager`)
- **Servers**: Astronomy themes (`andromeda`, `aether`, `callisto`)
- **Special**: `hyperion` (WSL)

### Code Style
- **Files**: `lowercase-with-hyphens.nix`
- **Nix variables**: `camelCase` (e.g., `myVariable`, `userName`)
- **Options**: `camelCase` (e.g., `services.myService.enableFeature`)
- **Environment variables**: `SCREAMING_SNAKE_CASE` (e.g., `API_KEY`)
- **Secrets**: `SCREAMING_SNAKE_CASE` (e.g., `DATABASE_PASSWORD`)
- **Entry points**: Always `default.nix`

### File Naming
- Module files: `service-name.nix`
- Hardware configs: `hardware.nix`, `facter.json`
- System configs: `configuration.nix`, `system.nix`
- Secrets: `secrets.sops.yaml`

## 🔧 Common Development Tasks

### Adding a New Host

1. Create host directory: `hosts/<hostname>/`
2. Create `default.nix` that imports necessary modules:
   ```nix
   { inputs, outputs, config, lib, pkgs, ... }:
   {
     imports = [
       inputs.nixos-facter-modules.nixosModules.facter
       ./hardware.nix
       ./configuration.nix
     ];
   }
   ```
3. Generate hardware config with nixos-facter:
   ```bash
   nixos-facter | tee hosts/<hostname>/facter.json
   ```
4. Create `hardware.nix` to import facter output:
   ```nix
   { config, ... }:
   {
     facter.reportPath = ./facter.json;
   }
   ```
5. Add to `flake.nix` imports section
6. If using secrets, add age key to `.sops.yaml`

### Adding a New Service Module

1. Create module file: `modules/nixos/<service>/default.nix`
2. Define options using `lib.mkOption` and `lib.mkEnableOption`
3. Register in `modules/nixos/default.nix`
4. Use in host configuration by enabling the service

Example module structure:
```nix
{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.services.myService = {
    enable = lib.mkEnableOption "My custom service";
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.myPackage;
      description = "Package to use for the service";
    };
  };
  
  config = lib.mkIf config.services.myService.enable {
    # Implementation here
    systemd.services.myService = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${config.services.myService.package}/bin/myservice";
        Restart = "on-failure";
      };
    };
  };
}
```

### Creating Custom Packages

1. Create package directory: `pkgs/<package-name>/`
2. Create `default.nix` with package definition
3. Register in `pkgs/default.nix`:
   ```nix
   {
     myPackage = pkgs.callPackage ./my-package { };
   }
   ```
4. Add to overlay in `flake.nix` if needed

Example package:
```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";
  
  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    sha256 = lib.fakeSha256; # Replace after first build
  };
  
  nativeBuildInputs = [ ];
  buildInputs = [ ];
  
  meta = with lib; {
    description = "Short description";
    homepage = "https://example.com";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
```

### Managing Secrets with SOPS

**CRITICAL**: All secrets must be encrypted with age before committing.

#### Secret Scopes (defined in `.sops.yaml`)
- `hosts/<hostname>/secrets/` - Host-specific secrets (only that host + admin)
- `secrets/` - Shared secrets (all hosts + admin)
- `k8s/` - Kubernetes secrets (specific hosts + admin)

#### Adding a New Secret

1. Create/edit the appropriate SOPS file:
   ```bash
   # For host-specific secrets
   sops hosts/<hostname>/secrets/secrets.sops.yaml
   
   # For shared secrets
   sops secrets/secrets.sops.yaml
   ```

2. Define the secret in a Nix configuration:
   ```nix
   { config, ... }:
   {
     sops.secrets.MY_SECRET = {
       owner = config.users.users.michael.name;
       group = config.users.users.michael.group;
       mode = "0400";
       sopsFile = ./secrets/secrets.sops.yaml;
     };
   }
   ```

3. Reference the secret path:
   ```nix
   services.myService.passwordFile = config.sops.secrets.MY_SECRET.path;
   ```

#### Age Keys
- User key: `age1chvcefkzfesskrs2vf7sp9fjktpx5z8qc4ggksuwfn483fwpjvxsv88jpa` (michael)
- Each host has its own age key in `.sops.yaml`
- Keys are automatically added for the appropriate scope

#### Updating Secret Keys
When adding a new host or user to existing secrets:
```bash
usops  # Updates all SOPS files with current keys from .sops.yaml
```

### Using the Custom OCI Compose Module

This repository has a custom module for docker-compose-like container definitions:

```nix
{
  virtualisation.oci-containers.compose.myService = {
    enable = true;
    
    networks.myNetwork = {
      driver = "bridge";
    };
    
    containers.app = {
      image = "myapp:latest";
      ports = [ "8080:8080" ];
      environment = {
        APP_ENV = "production";
      };
      volumes = [
        "/host/path:/container/path:ro"
      ];
      networks.myNetwork = { };
    };
    
    containers.database = {
      image = "postgres:16";
      environment = {
        POSTGRES_PASSWORD_FILE = config.sops.secrets.DB_PASSWORD.path;
      };
      volumes = [
        "postgres_data:/var/lib/postgresql/data"
      ];
      networks.myNetwork = { };
    };
  };
}
```

## 🛠️ Development Environment

### Entering the Dev Shell

The repository provides a development shell with all necessary tools:

```bash
# Option 1: Manual
nix develop

# Option 2: Automatic with direnv (if .envrc exists)
direnv allow
```

### Available Tools in Dev Shell

**Nix Utilities:**
- `nixpkgs-fmt` - Nix formatter
- `nixfmt` (`pkgs.nixfmt`) - RFC-style Nix formatter (preferred, `nixfmt-rfc-style` is now an alias)
- `statix` - Linter for anti-patterns
- `nix-output-monitor` (nom) - Better build output
- `nix-tree` - Visualize dependency trees
- `nix-init` - Quick package scaffolding
- `nixos-generators` - Generate images
- `nixos-facter` - Hardware detection

**Deployment & Secrets:**
- `deploy-rs` - Remote deployment
- `sops` - Secret management
- `ssh-to-age` - Convert SSH keys to age

**Custom Commands:**
- `dply <hostname>` - Deploy to remote server with pretty output
- `evl <hostname>` - Evaluate NixOS configuration
- `usops` - Update all SOPS secrets with current keys

### Testing Changes

Nix flakes only include **git-tracked files** (committed or staged). New files that haven't been added to git will be silently ignored, causing confusing "file not found" import errors.

**Always stage new files before building:**

```bash
# Stage any new or modified files first
git add -A   # or: git add <specific-file>

# Then dry-build to verify
nixos-rebuild dry-build --flake .#<hostname>
```

This does **not** require committing — staging alone is sufficient for the flake evaluator to see the files.

Full verification workflow:

1. **Stage changes** (required for new files):
   ```bash
   git add -A
   ```

2. **Dry build** (check for errors):
   ```bash
   nixos-rebuild dry-build --flake .#<hostname>
   ```

3. **Build without switching** (create result symlink):
   ```bash
   nixos-rebuild build --flake .#<hostname>
   ```

4. **Evaluate specific options**:
   ```bash
   nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel
   nix eval .#nixosConfigurations.<hostname>.config.networking.hostName
   ```

5. **Check flake**:
   ```bash
   nix flake check
   nix flake metadata
   ```

### Applying Changes Locally

```bash
# Switch to new configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Test configuration (switch but rollback on reboot)
sudo nixos-rebuild test --flake .#<hostname>

# Boot into new configuration (doesn't activate immediately)
sudo nixos-rebuild boot --flake .#<hostname>
```

### Deploying to Remote Hosts

```bash
# Using the custom deploy command (with pretty output)
dply .#<hostname>

# Using deploy-rs directly
deploy .#<hostname>

# Deploy all hosts
deploy .
```

## 📝 Code Patterns and Best Practices

### Module Structure

Follow this standard pattern for all custom modules:

```nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.myService;
in
{
  options.services.myService = {
    enable = lib.mkEnableOption "my service";
    
    # More options...
  };
  
  config = lib.mkIf cfg.enable {
    # Implementation
  };
}
```

### Using `lib` Functions

Common patterns:
- `lib.mkIf condition { }` - Conditional configuration
- `lib.mkDefault value` - Default value (can be overridden)
- `lib.mkForce value` - Force value (high priority)
- `lib.mkMerge [ ]` - Merge attribute sets
- `lib.mkBefore [ ]` - Insert before existing list items
- `lib.mkAfter [ ]` - Insert after existing list items
- `lib.optional condition value` - Conditionally include value in list
- `lib.optionalAttrs condition { }` - Conditionally include attributes

### Home Manager Integration

Home Manager configs typically live in:
- `users/<username>/` - User-specific Home Manager configs
- Imported in host `default.nix` or `configuration.nix`

Example:
```nix
{
  home-manager.users.michael = { ... }: {
    home.packages = with pkgs; [
      firefox
      vscode
    ];
    
    programs.git = {
      enable = true;
      userName = "Michael";
      userEmail = "michael@example.com";
    };
  };
}
```

### Systemd Services

Pattern for creating systemd services:

```nix
{
  systemd.services.myService = {
    description = "My Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.myPackage}/bin/myservice";
      Restart = "on-failure";
      RestartSec = "5s";
      
      # Security hardening
      DynamicUser = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };
}
```

### Networking Configuration

```nix
{
  networking = {
    hostName = "hostname";
    domain = "example.com";
    
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPorts = [ ];
    };
    
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.1.100";
      prefixLength = 24;
    }];
  };
}
```

## 🚀 Deployment Workflows

### Local Development Workflow

1. Make changes to configuration files
2. Format with `nixfmt <file>`
3. Stage changes: `git add -A` (required — flakes only see git-tracked files)
4. Test build: `nixos-rebuild dry-build --flake .#<hostname>`
5. Review changes carefully
6. Apply: `sudo nixos-rebuild switch --flake .#<hostname>`
7. Verify system is working correctly
8. Commit changes to git

### Remote Deployment Workflow

1. Make changes locally
2. Stage and test: `git add -A && nixos-rebuild dry-build --flake .#<hostname>`
3. Commit changes to git
4. Deploy: `dply .#<hostname>`
5. Monitor deployment output
6. Verify remote system via SSH
7. If issues occur, rollback: `ssh <hostname> sudo nixos-rebuild switch --rollback`

### Updating Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Update and rebuild
nix flake update && nixos-rebuild build --flake .#<hostname>
```

## 🐛 Debugging and Troubleshooting

### Common Issues

**Build fails with "attribute missing":**
- Check for typos in option names
- Verify module is imported
- Check if option exists: `nix eval .#nixosConfigurations.<hostname>.options.services.myService`

**Secret decryption fails:**
- Verify age key exists: `ls -la /etc/ssh/ssh_host_ed25519_key`
- Check `.sops.yaml` includes the host key
- Update secret keys: `usops`

**Service fails to start:**
- Check logs: `journalctl -u service-name -f`
- Verify systemd config: `systemctl cat service-name`
- Check file permissions on secret paths

**Build is slow:**
- Use binary cache: Check `nixConfig` in `flake.nix`
- Use `nom` for better build output: `nom build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- Enable parallel builds: `nix.settings.max-jobs` in config

### Useful Debug Commands

```bash
# View system configuration
nixos-option <option-path>

# Check what's currently running
systemctl status

# View recent system logs
journalctl -b

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Compare configurations
nix store diff-closures /nix/var/nix/profiles/system-{42,43}-link

# View dependency tree
nix-tree /run/current-system

# Check flake metadata
nix flake metadata
nix flake show
```

## 📋 Code Review Checklist

When reviewing changes (for AI agents or humans):

- [ ] Code is formatted with `nixfmt` (`pkgs.nixfmt`)
- [ ] Indentation uses tabs (size 2)
- [ ] No syntax errors: `nix flake check`
- [ ] Builds successfully: `nixos-rebuild dry-build --flake .#<hostname>`
- [ ] Secrets are encrypted with SOPS (no plaintext secrets)
- [ ] Options have proper types and descriptions
- [ ] Module follows standard structure (options → config with mkIf)
- [ ] Systemd services have proper `after`, `wantedBy`, and `serviceConfig`
- [ ] Documentation updated if needed (README.md, this file)
- [ ] Commit message is descriptive
- [ ] Changes follow existing patterns in the codebase

## 🔍 Useful References

### Official Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [SOPS-nix](https://github.com/Mic92/sops-nix)

### Repository-Specific
- `README.md` - Repository overview and quick start
- `.github/copilot-instructions.md` - Detailed agent instructions (original version)
- `flake.nix` - Main flake configuration
- `.sops.yaml` - Secret encryption configuration
- `.editorconfig` - Code style settings

### Search Tools
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Packages Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)

## 🎓 Learning Resources for AI Agents

When you encounter unfamiliar patterns:

1. **Search the codebase**: Look for similar examples
   ```bash
   grep -r "pattern" hosts/ modules/
   ```

2. **Check existing modules**: See how others are structured
   ```bash
   ls -la modules/nixos/
   ```

3. **Evaluate options**: See what's available
   ```bash
   nix eval .#nixosConfigurations.<hostname>.options.<path>
   ```

4. **Read the source**: nixpkgs source is your friend
   ```bash
   # View nixpkgs source for a module
   nix eval nixpkgs#nixosModules.<module>.meta.doc
   ```

## 📌 Final Notes

- **This is a production system**: Changes affect real machines. Test thoroughly.
- **Secrets are sensitive**: Never log, print, or expose secret values.
- **Follow conventions**: Consistency makes maintenance easier.
- **Document changes**: Help future contributors understand your decisions.
- **Ask when uncertain**: Better to ask than to break a working system.

---

**Last Updated**: 2026-02-25  
**Maintainer**: Michael  
**Repository**: https://github.com/MasterMidi/nixos-config

For issues or questions, refer to README.md or check existing code patterns.
