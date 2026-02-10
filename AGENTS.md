# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this NixOS configuration repository.

## Build/Lint/Test Commands

### Primary Commands (using Justfile)
```bash
just fmt                    # Format code with treefmt (nixpkgs-fmt)
just check                  # Run nix flake check (validation)
just build                  # Build configuration without applying
just trace                  # Build with full error traces
just switch                 # Apply configuration to system (requires sudo)
just boot                   # Set configuration for next boot
just update                 # Update flake inputs and commit
just show                   # Show flake outputs
just garbage               # Clean up old generations
just optimise              # Optimise nix store
```

### Development Workflow
```bash
nix flake check            # Validate flake structure
nixos-rebuild test         # Test configuration (temporary)
treefmt                    # Format Nix files directly
sops                       # Manage secrets (available in devShell)
```

### Single Test/Module Validation
NixOS doesn't use traditional unit tests. To validate individual modules:
```bash
nix eval .#nixosConfigurations.wuwei.config.services.openssh.enable
nix build .#nixosConfigurations.wuwei.config.system.build.toplevel
```

## Code Style Guidelines

### File Structure & Imports
```nix
# Standard parameter order (alphabetical when possible)
{ flake, pkgs, lib, config, ... }:

let
  inherit (flake) inputs;     # Standard inheritance
  inherit (inputs) self;
in
{
  imports = [
    "${self}/os/nix.nix"      # Absolute paths with self/
    ./filesystems.nix         # Relative paths for local files
    self.nixosModules.default # Module references
  ];
}
```

### Naming Conventions
- **camelCase**: `installationPath`, `libPath`, `appendPath`
- **snake_case**: `home.packages`, `system.stateVersion`, `networking.firewall`
- **kebab-case**: `xerox_phaser_p3250`, `nixpkgs-unstable`
- **UPPER_CASE**: Environment variables (`CODESTATS_API_KEY`)

### Formatting Rules
- **Indentation**: 2 spaces (no tabs)
- **Attribute sets**: Align consistently, expand for complex structures
- **Lists**: Single line for short lists, multi-line with alignment for longer ones

```nix
# Compact simple sets
{ description = "Brcha's NixOS configuration"; }

# Expanded complex sets
nix = {
  nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ];
  settings = {
    max-jobs = 1;
    cores = 4;
    experimental-features = "nix-command flakes ca-derivations";
  };
};
```

### Import Organization
1. `${self}/` paths for absolute imports within flake
2. `./` for relative imports in same directory  
3. Module references (`self.nixosModules.*`)
4. Group similar imports together
5. Comment disabled imports for future reference

### Comment Style
```nix
# Single-line comments with space after #
# Section headers for organization

# Localization
time.timeZone = "Europe/Belgrade";

# Inline comments explain specific values
cores = 4;  ## END TEMP CHANGES

# Comment blocks for disabled code
# plasma5 = {
#   enable = true;
# };
```

### String Quoting
```nix
# Double quotes for most strings
description = "Brcha's NixOS configuration";

# Single quotes for strings with double quotes or special chars  
less = ''bat --pager="less -RFX"'';

# Multi-line strings with double quotes
extraConfig = ''
  " Setup Code::Stats
  source ${config.sops.secrets.codestats-key-neovim.path}
'';
```

### Module Structure
```nix
{ lib, ... }:
{
  options = {
    myService.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Multi-line description
        of what this option does
      '';
    };
  };
  
  config = {
    # Default configuration
    services.myService = lib.mkIf config.myService.enable {
      # Service configuration
    };
  };
}
```

### Type Annotations
```nix
options = {
  name = lib.mkOption {
    type = lib.types.str;
    description = "Display name of the user";
  };
  
  sshKeys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "SSH public keys";
  };
}
```

### Error Handling
```nix
# Platform-specific handling
installationPath = 
  if stdenv.hostPlatform.system == "x86_64-linux" then "x86_64" else "i386";

# Fallback values
configurationRevision = self.rev or self.dirtyRev or "empty";

# Error prevention comments
# vim-fsharp # BROKEN at the moment
```

## NixOS-Specific Patterns

### Flake Structure (flake-parts + nixos-unified)
```nix
outputs = inputs@{ self, flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } (
  { withSystem, lib, ... }: {
    systems = [ "x86_64-linux" ];
    
    imports = [
      inputs.treefmt-nix.flakeModule
      inputs.nixos-unified.flakeModule
      ./users
      ./os
      ./home
    ];
  }
);
```

### Home-Manager Integration
```nix
home-manager.users.${config.people.me} = {
  imports = [
    self.homeModules.common-linux
  ];
  # User-specific home configuration
};
```

### SOPS Secrets Management
```nix
sops.secrets.my-secret = {
  neededForUsers = true;
  # sops.yaml defines encryption keys
};
```

### Overlay Patterns
```nix
flake.overlays.unstable = (final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config = prev.config;
  };
});
```

## Development Guidelines

### Environment Setup
- Use `direnv` with `use flake` (automatically enabled via .envrc)
- Development shell includes `just` and `sops` commands
- Run `nix flake update` via `just update` (auto-commits changes)

### Module Creation
1. Create focused, single-responsibility modules
2. Follow established naming patterns (`gui/kde.nix`, `servers/postgresql.nix`)
3. Include proper type annotations and descriptions
4. Use conditional enablement with `lib.mkIf`

### Package Management
- Use `with pkgs;` for package lists in home-manager
- Prefer unstable packages via `pkgs.unstable.package-name`
- Handle platform-specific packages with conditionals

### Git Workflow
- Feature branches for major changes
- Use `git town sync` (available via `just sync`)
- Commit flake.lock updates with standardized message: "build: update flake inputs"

## Important Notes

- **State Version**: Update from "22.05" to "25.11" in machine configs
- **Resource Constraints**: Build system limited to `max-jobs = 1`, `cores = 4`
- **Secrets**: All sensitive data managed via SOPS in `secrets/` directory
- **Modularization**: Avoid monolithic files like `home/therest_to_be_modularized.nix`

## Testing Strategy

- Validate flake structure: `just check`
- Test builds before applying: `just build` or `just trace`
- Use `nix eval` for specific option testing
- Secrets validation: `sops --encrypt --in-place secrets/file.yaml`

Remember: This is a NixOS configuration - changes affect the entire system. Always build and test before switching!