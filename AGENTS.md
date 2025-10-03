# NixOS Configuration - AI Agent Instructions

This document provides guidelines and conventions for working with this NixOS configuration repository. It's designed to help AI agents and new contributors understand the repository layout, naming conventions, and structural patterns.

## Repository Overview

This is a flake-based NixOS configuration repository that manages multiple machines (desktops and servers) with shared configurations and custom packages. The repository uses:

- **NixOS Flakes** for reproducible builds
- **Home Manager** for user environment management
- **SOPS-nix** for secrets management
- **Custom modules** for reusable configurations
- **Overlays** for package customization

## Directory Structure

```
nixos-config/
├── .github/              # GitHub workflows and repository metadata
├── flake.nix             # Main flake configuration defining all systems
├── flake.lock            # Pinned flake inputs
├── shell.nix             # Development shell with tools
├── machines/             # Machine-specific configurations
│   ├── desktops/         # Desktop machine configurations
│   │   ├── jason/        # Individual desktop (hostname: jason)
│   │   ├── daniel/       # Individual desktop (hostname: daniel)
│   │   └── shared/       # Shared desktop configurations
│   ├── servers/          # Server machine configurations
│   │   ├── andromeda/    # Individual server (hostname: andromeda)
│   │   ├── nova/         # Individual server (hostname: nova)
│   │   ├── pisces/       # Individual server (hostname: pisces)
│   │   └── shared/       # Shared server configurations (if exists)
│   └── shared/           # Configurations shared across all machines
│       ├── core/         # Core system configurations
│       └── avahi.nix     # Shared service configurations
├── modules/              # Custom NixOS modules
│   ├── options/          # Custom module options
│   ├── services/         # Custom service modules
│   ├── configs/          # Configuration modules
│   └── default.nix       # Module exports
├── pkgs/                 # Custom package definitions
│   ├── default.nix       # Package overlay
│   └── <package-name>/   # Individual package directories
├── overlays/             # Nixpkgs overlays
│   └── default.nix       # Overlay definitions
├── secrets/              # Encrypted secrets (SOPS)
│   ├── system/           # System-level secrets
│   ├── users/            # User-level secrets
│   └── default.nix       # Secrets configuration
├── scripts/              # Utility scripts
│   ├── update.sh         # Update flake inputs
│   ├── switch.sh         # Rebuild and switch configuration
│   └── upgrade.sh        # Update and rebuild
└── .sops.yaml            # SOPS configuration with age keys
```

## Naming Conventions

### Hostnames
- **Desktops**: Named after people (e.g., `jason`, `daniel`)
- **Servers**: Named after space/astronomy themes (e.g., `andromeda`, `nova`, `pisces`)
- Future machine names should follow these themes

### Files and Directories
- **default.nix**: Main entry point for any directory, imports all configurations
- **Use lowercase with hyphens** for multi-word names: `some-module.nix`
- **Service files**: Named after the service they configure (e.g., `ollama.nix`, `jellyfin.nix`)
- **Descriptive names**: Files should clearly indicate their purpose (e.g., `hardware/`, `services/`, `networking.nix`)

### Variables and Attributes
- Use **camelCase** for Nix variables: `composeName`, `containerName`
- Use **SCREAMING_SNAKE_CASE** for environment variables and secrets: `AUTHENTIK_SECRET_KEY`
- Use **lowercase with hyphens** for attribute sets keys that map to system services

## Machine Configuration Structure

Each machine follows a standard directory structure:

```
machines/<type>/<hostname>/
├── default.nix           # Main configuration, imports all modules
├── hardware/             # Hardware-specific configuration
│   ├── default.nix       # Hardware imports
│   ├── facter.json       # Hardware detection output (optional)
│   └── disko.nix         # Disk partitioning (optional)
├── filesystem/           # Filesystem configuration (alternative to disko)
│   ├── default.nix
│   └── disko.nix
├── home/                 # Home Manager configuration
│   ├── default.nix       # Home Manager imports
│   └── home.nix          # User-specific home configuration
├── services/             # Service configurations
│   ├── default.nix       # Service imports
│   └── <service>.nix     # Individual service configurations
├── secrets/              # Machine-specific secrets
│   ├── default.nix       # Secret definitions
│   └── secrets.sops.yaml # Encrypted secrets file
├── networking.nix        # Network configuration
├── system.nix            # System-level settings
├── graphical.nix         # GUI/desktop environment (desktops only)
├── development.nix       # Development tools (optional)
├── gaming.nix            # Gaming configuration (optional)
├── security.nix          # Security settings (optional)
├── sound.nix             # Audio configuration (optional)
└── virtualization.nix    # VM/container settings (optional)
```

## Module Development Guidelines

### Custom Modules Structure

Modules are organized in `modules/` with a clear separation:

```
modules/
├── options/              # Module option definitions
│   └── <module-name>/
│       ├── default.nix   # Options declaration
│       └── options.nix   # Detailed option types
├── services/             # Service implementations
│   └── <service-name>/
│       ├── default.nix   # Service module
│       └── config.nix    # Service config (if complex)
└── configs/              # Configuration modules
    └── <config-name>/
        └── default.nix
```

### Module Option Pattern

When creating new options, follow this pattern:

```nix
{ lib, config, ... }:
{
  options.services.myService = {
    enable = lib.mkEnableOption "Enable my service";
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };
    
    # More options...
  };
  
  config = lib.mkIf config.services.myService.enable {
    # Implementation
  };
}
```

## Package Development

### Custom Packages Structure

Custom packages go in `pkgs/<package-name>/`:

```
pkgs/<package-name>/
├── default.nix           # Package definition
└── <sources>/            # Local sources (if needed)
```

### Package Definition Pattern

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies...
}:
stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    sha256 = "sha256-...";
  };

  # Build instructions...

  meta = with lib; {
    description = "Description of the package";
    homepage = "https://example.com";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
```

Packages are registered in `pkgs/default.nix` using `callPackage`.

## Code Style and Formatting

### Nix Code Style
- **Formatter**: Use `nixfmt-rfc-style` for formatting Nix code
- **Indentation**: Use tabs with size 2 (as per `.editorconfig`)
- **Line endings**: LF (Unix-style)
- **Trailing whitespace**: Remove all trailing whitespace
- **Final newline**: Always include a final newline

### EditorConfig Settings
The repository includes `.editorconfig` for consistent formatting:
- Tab indentation (size 2) for most files
- Space indentation for YAML files
- UTF-8 encoding
- LF line endings

### Nix Expressions
- Use `lib.mkIf` for conditional configuration
- Use `lib.mkOption` for all module options with proper types
- Use `lib.mkEnableOption` for boolean enable options
- Always provide descriptions for options
- Prefer `imports` over inline configuration
- Keep expressions readable; break long lines appropriately

## Secrets Management

### SOPS Configuration
- All secrets are encrypted using **age** encryption
- Age keys are defined in `.sops.yaml` for users and hosts
- Secrets files use `.sops.yaml` extension for YAML secrets
- Secret paths must match the pattern in `.sops.yaml`

### Secret Definition Pattern

In `secrets/<scope>/default.nix`:

```nix
{ config, ... }:
{
  sops.secrets.SECRET_NAME = {
    owner = config.users.users.username.name;
    group = config.users.groups.groupname.name;
    sopsFile = ./secrets.sops.yaml;
  };
}
```

### Secret Scopes
- **system/**: System-level secrets (all machines)
- **users/**: User-level secrets (Home Manager)
- **machines/<hostname>/secrets/**: Machine-specific secrets

## Home Manager Configuration

### Structure
- Shared home configurations in `machines/desktops/shared/home/`
- User-specific configurations in `machines/<type>/<hostname>/home/`
- Always separate user environment from system configuration

### Pattern for User Configuration

```nix
{ pkgs, ... }:
{
  home-manager.users.username = {
    imports = [
      # Import shared and specific configs
    ];
    
    home.packages = with pkgs; [
      # User packages
    ];
    
    programs.someProgram = {
      enable = true;
      # Configuration
    };
  };
}
```

## Flake Structure

### Flake Inputs
Organized by category with comments:
- **Packages**: Main package sources (nixpkgs)
- **Premade modules**: Community modules (home-manager, disko, etc.)
- **Development tools**: Language-specific tools (rust-overlay)
- **Deployment & secrets**: Deployment and secret management tools
- **Theming**: UI customization inputs
- **Utilities**: Nix/flake utilities

### Flake Outputs
- `nixosConfigurations.<hostname>`: NixOS system configurations
- `overlays`: Package overlays
- `nixosModules`: Custom module exports
- `devShells`: Development environments (via shell.nix)
- `images.<hostname>`: System images (e.g., SD cards for Raspberry Pi)

## Development Workflow

### Dev Shell Commands
The `shell.nix` provides custom commands:
- `nix-update`: Update flake inputs
- `dply <hostname>`: Deploy to remote server
- `evl <hostname>`: Evaluate NixOS configuration
- `usops`: Update all SOPS secrets with current keys

### Common Operations

#### Adding a New Machine
1. Create directory: `machines/<type>/<hostname>/`
2. Create `default.nix` with imports
3. Add hardware configuration
4. Add to `flake.nix` in `nixosConfigurations`
5. Add age key to `.sops.yaml` if using secrets

#### Adding a New Service
1. Create service file: `machines/<hostname>/services/<service>.nix`
2. Import in `services/default.nix`
3. Configure service options
4. Add any required secrets to secrets configuration

#### Adding a New Module
1. Create module in `modules/options/<module>/`
2. Define options in `default.nix`
3. Export in `modules/options/default.nix`
4. Implement in machine configurations as needed

## Best Practices

### Configuration
- **DRY Principle**: Use shared configurations for common settings
- **Modularity**: Keep configurations small and focused
- **Imports**: Prefer importing separate files over large monolithic configs
- **Documentation**: Add comments for non-obvious decisions (see TODO.md note #9)
- **Conditionals**: Use `lib.mkIf` for optional features

### Security
- Never commit unencrypted secrets
- Use SOPS for all sensitive data
- Keep `.sops.yaml` updated with all machine age keys
- Regular key rotation for sensitive services

### Testing
- Test configurations with `nixos-rebuild dry-build` before applying
- Use `nix flake check` to validate flake structure (when available)
- Test deployments on non-critical machines first

### Performance
- Use `nix-output-monitor` for better build visibility
- Enable binary caches where appropriate
- Consider remote builders for large builds (see TODO.md)

## Common Patterns

### Service with Secrets
```nix
{ config, ... }:
{
  # Secret definition
  sops.secrets.SERVICE_PASSWORD = {
    owner = config.users.users.michael.name;
    sopsFile = ./secrets.sops.yaml;
  };

  # Service configuration
  services.myService = {
    enable = true;
    passwordFile = config.sops.secrets.SERVICE_PASSWORD.path;
  };
}
```

### Container Service with Compose Module
The repository includes a custom `compose` module for OCI containers:

```nix
{
  virtualisation.oci-containers.compose.myService = {
    enable = true;
    containers.main = {
      image = "myimage:latest";
      environment = {
        VAR = "value";
      };
      volumes = [
        "/host/path:/container/path"
      ];
      networks.myNetwork = {
        # Network config
      };
    };
  };
}
```

### Hardware Configuration
```nix
{ inputs, modulesPath, ... }:
{
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  facter.reportPath = ./facter.json;
}
```

## Reference Documentation

### Important Files
- **flake.nix**: Main entry point, defines all systems and inputs
- **shell.nix**: Development environment
- **.sops.yaml**: Secrets encryption configuration
- **.editorconfig**: Code style settings
- **TODO.md**: Current tasks and future improvements

### Key Technologies
- NixOS: Declarative Linux distribution
- Nix Flakes: Reproducible dependency management
- Home Manager: User environment management
- SOPS: Secrets management with age encryption
- nixos-facter: Hardware detection alternative

### External Resources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Troubleshooting

### Common Issues
- **Build failures**: Check `nix flake check` and individual builds
- **Secret access**: Ensure age keys are correctly configured in `.sops.yaml`
- **Module not found**: Verify imports in `modules/default.nix`
- **Home Manager conflicts**: Check for duplicate option definitions

### Debug Commands
```bash
# Check configuration
nixos-rebuild dry-build

# Evaluate specific option
nix eval .#nixosConfigurations.hostname.config.some.option

# Check flake metadata
nix flake metadata

# Update and test
nix flake update && nixos-rebuild dry-build
```

## Maintaining This Documentation

### For AI Agents

**IMPORTANT**: This AGENTS.md file must be kept up-to-date with the actual repository structure and conventions.

When working in this repository, you **MUST**:

1. **Update this file when making structural changes**:
   - Adding/removing/renaming directories
   - Changing naming conventions
   - Introducing new patterns or workflows
   - Modifying the module system or package structure
   - Updating secrets management approaches

2. **Verify consistency when you detect discrepancies**:
   - If you find that actual code doesn't match these instructions, determine which is correct
   - Update this file if the instructions are outdated
   - Fix the code if it violates documented conventions
   - Document your findings in commit messages

3. **Document new patterns immediately**:
   - When introducing a new structural pattern, add it to the relevant section
   - Include code examples for complex patterns
   - Update the "Common Patterns" section with reusable examples

4. **Before completing any task**:
   - Review the changes you made against this documentation
   - Update any affected sections in AGENTS.md
   - Ensure examples remain accurate and relevant
   - Include documentation updates in the same commit as code changes when possible

### Keeping Documentation Accurate

- **Structure changes**: Update the "Directory Structure" section
- **New conventions**: Update the "Naming Conventions" section  
- **New modules/packages**: Update relevant development guidelines
- **Workflow changes**: Update the "Development Workflow" section
- **New best practices**: Add to the "Best Practices" section

This file is a **living document** - it should evolve with the repository. Outdated documentation is worse than no documentation.

## Contributing Guidelines

When making changes:
1. Follow existing patterns and conventions
2. Test changes with dry-build before applying
3. Update documentation if adding new patterns
4. Keep commits focused and well-described
5. Use the dev shell tools for consistency
6. **Update AGENTS.md if your changes affect repository structure or conventions**

---

*This repository is actively maintained. Check TODO.md for current priorities and planned improvements.*
