# Repository-Specific Instructions for AI Agents

## Critical Rules

**ALWAYS** follow these rules when working in this repository:

1. **Use `nixfmt-rfc-style` for all Nix code formatting** - Never use other formatters
2. **Use tabs (size 2) for indentation** - As defined in `.editorconfig`
3. **Test with `nixos-rebuild dry-build`** before applying any NixOS configuration changes
4. **Never commit unencrypted secrets** - All secrets must use SOPS encryption with age keys
5. **Update this file** when making structural changes, new patterns, or convention updates
6. **Update README.md and TODO.md** when changes affect repository features or tasks

## Technology Stack

This is a **flake-based NixOS configuration** repository managing multiple machines:
- **NixOS Flakes** - Reproducible system builds
- **Home Manager** - User environment management  
- **SOPS-nix** - Secrets management with age encryption
- **Custom modules** - Reusable configuration patterns
- **OCI containers** - Custom compose module for services

## Repository Structure

**Key directories:**
- `machines/<type>/<hostname>/` - Per-machine configurations
- `machines/shared/` - Shared across all machines
- `modules/options/` - Custom module definitions
- `modules/services/` - Custom service modules
- `pkgs/` - Custom packages (registered in `pkgs/default.nix`)
- `secrets/` - SOPS-encrypted secrets (.sops.yaml files)

**Standard machine layout:**
```
machines/<type>/<hostname>/
├── default.nix        # Imports all modules below
├── hardware/          # nixos-facter hardware config
├── home/              # Home Manager user config
├── services/          # Service configurations
├── secrets/           # Machine-specific SOPS secrets
└── [networking.nix, system.nix, graphical.nix, ...]
```

## Naming Conventions

### Hostnames
- **Desktops**: People names (`jason`, `daniel`)
- **Servers**: Space/astronomy themes (`andromeda`, `nova`, `pisces`)

### Code Conventions
- **Files**: `lowercase-with-hyphens.nix`
- **Nix variables**: `camelCase`
- **Environment variables/secrets**: `SCREAMING_SNAKE_CASE`
- **Entry points**: Always use `default.nix` to import configurations

## Development Patterns

### Adding a New Machine
1. Create `machines/<type>/<hostname>/default.nix`
2. Add hardware config in `hardware/`
3. Add to `flake.nix` nixosConfigurations
4. If using secrets: Add age key to `.sops.yaml`

### Adding a New Service
1. Create `machines/<hostname>/services/<service>.nix`
2. Import in `services/default.nix`
3. Add secrets to `secrets/default.nix` if needed

### Creating Custom Modules
1. Define options in `modules/options/<module>/default.nix`
2. Export in `modules/options/default.nix`
3. Use `lib.mkOption` with proper types and descriptions
4. Use `lib.mkEnableOption` for boolean enables

### Custom Packages
1. Create `pkgs/<package-name>/default.nix`
2. Register using `callPackage` in `pkgs/default.nix`
3. Include proper `meta` with description, license, maintainers

## Code Examples

### Module Options Pattern
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
  };
  
  config = lib.mkIf config.services.myService.enable {
    # Implementation
  };
}
```

### Package Definition Pattern
```nix
{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";
  
  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    sha256 = "sha256-...";
  };
  
  meta = with lib; {
    description = "Description of the package";
    homepage = "https://example.com";
    license = licenses.mit;
  };
}
```

### Service with Secrets
```nix
{ config, ... }:
{
  sops.secrets.SERVICE_PASSWORD = {
    owner = config.users.users.michael.name;
    sopsFile = ./secrets.sops.yaml;
  };
  
  services.myService = {
    enable = true;
    passwordFile = config.sops.secrets.SERVICE_PASSWORD.path;
  };
}
```

### OCI Container with Compose Module
```nix
{
  virtualisation.oci-containers.compose.myService = {
    enable = true;
    containers.main = {
      image = "myimage:latest";
      environment.VAR = "value";
      volumes = [ "/host:/container" ];
      networks.myNetwork = {};
    };
  };
}
```

## Dev Shell Commands

Available in `nix develop` or with direnv:
- `nix-update` - Update flake inputs
- `dply <hostname>` - Deploy to remote server
- `evl <hostname>` - Evaluate NixOS configuration
- `usops` - Update SOPS secrets with current keys

## Secrets Management (SOPS)

**Critical:** All secrets MUST be encrypted with age:

1. Define secret in `secrets/<scope>/default.nix`:
```nix
sops.secrets.SECRET_NAME = {
  owner = config.users.users.username.name;
  sopsFile = ./secrets.sops.yaml;
};
```

2. Reference in config: `config.sops.secrets.SECRET_NAME.path`
3. Age keys must be in `.sops.yaml` for all hosts/users
4. Secret scopes:
   - `secrets/system/` - System-level (all machines)
   - `secrets/users/` - User-level (Home Manager)
   - `machines/<hostname>/secrets/` - Machine-specific

## Maintaining Documentation

**When you make changes, update:**
- **This file** - Structure/convention changes
- **README.md** - Features, usage, repository overview changes  
- **TODO.md** - New tasks or completed items

**Consistency checks:**
- If code doesn't match instructions → determine which is correct
- Update docs if instructions are outdated
- Fix code if it violates documented conventions
- Document findings in commit messages

## References

**Important files:**
- `flake.nix` - Main entry point, defines all systems
- `shell.nix` - Development environment with custom commands
- `.sops.yaml` - Secrets encryption configuration
- `.editorconfig` - Code style settings (tabs size 2, LF line endings)
- `TODO.md` - Current tasks and priorities

**Flake outputs:**
- `nixosConfigurations.<hostname>` - System configurations
- `overlays` - Package overlays
- `nixosModules` - Custom module exports  
- `images.<hostname>` - System images (SD cards for RPi)

**Testing commands:**
- `nixos-rebuild dry-build` - Test configuration
- `nix eval .#nixosConfigurations.<hostname>.config.<option>` - Evaluate options
- `nix flake metadata` - Check flake metadata

---

*See TODO.md for current priorities. See README.md for repository overview.*
