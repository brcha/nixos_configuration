# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this NixOS configuration repository.

## Subpart Documentation

Each major subdirectory has its own AGENTS.md with component-specific conventions:

- [`home/AGENTS.md`](home/AGENTS.md) — home-manager layer overview and cross-cutting conventions
- [`home/development/AGENTS.md`](home/development/AGENTS.md) — language toolchains and dev CLIs, VCS, formatters, Neovim, AI tools
- [`home/apps/AGENTS.md`](home/apps/AGENTS.md) — end-user GUI applications (browser, media, games, communication, security)
- [`home/tools/AGENTS.md`](home/tools/AGENTS.md) — CLI utilities, shell configuration, system tools, networking, documents
- [`os/AGENTS.md`](os/AGENTS.md) — NixOS system-level configuration layer overview
- [`os/gui/AGENTS.md`](os/gui/AGENTS.md) — GUI environment modules (KDE Plasma, fonts, Flatpak, Hyprland, SSH agent)
- [`os/servers/AGENTS.md`](os/servers/AGENTS.md) — system service modules (databases, VPN, sync, AI, etc.)

## Documentation

- [`doc/`](doc/) — user-facing documentation, for people rather than agents
  - [`doc/hyprland.md`](doc/hyprland.md) — Hyprland session: keybindings, desktop shell, KDE integration notes. Update it whenever binds or the shell change

## Architecture

### Layers

- `os/` — NixOS modules that do not depend on a machine. No host paths, interface names or per-host values.
- `home/` — home-manager modules, OS-agnostic. Platform-specific parts are guarded (`pkgs.stdenv.isLinux`) so the same modules work on Linux, Darwin and WSL.
- `machines/<host>/` — everything specific to one machine: hardware, disks, boot, persistence, interface names, build limits, data paths, and which switches are on.
- `options/` — the `my.*` switches shared by NixOS and home-manager.
- `lib/` — small helpers: `group.nix` builds a switch group, `available.nix` gives home modules the `available` package filter.
- `users/` — `flake.config.people`: the users and their per-user data (keys, location, ledger and todo files). Home modules read it instead of hard-coding user values.
- `tests/` — evaluation tests, the VM test and the Darwin and WSL home builds (see Testing Strategy).
- A service module configures only its own service. Shared concerns (the firewalld zones, for example) live in their own `os/` module (`os/firewall.nix`), and a service only plugs itself in (Tailscale adds `tailscale0` to the `internal` zone).

### Switches (`my.*`)

- Every optional module is behind a `my.*` switch, off by default; the machine turns on what it uses in `machines/<host>/default.nix`. Core modules stay always on: `nixosModules.common` (sops, nix, users, zsh) and `nixosModules.linux` (base, dns, firewall, openssh, system).
- One switch per feature, spanning layers where needed: `my.hyprland.enable` and `my.kde.enable` gate both the `os/gui/` module and the matching `home/apps/` modules, and both assert `my.gui.enable`.
- Groups (built with `lib/group.nix`): `my.dev`, `my.apps`, `my.gui`, `my.virtualisation`. A child defaults to its group switch, so `my.dev.enable = true` turns on every child, `my.dev.haskell = false` drops one, and `my.dev.go = true` works with the group off. Exception: `my.virtualisation.virtualbox` is independent of its group and off by default.
- Other switches: `my.hardware.{sound,printing,razer}.enable`, `my.servers.<name>.enable` (one per `os/servers/` module), and `my.tools.hardware` (on by default; the hardware and disk CLIs in `home/tools/hardware.nix`).
- Shared switches (`my.hyprland`, `my.kde`, `my.tools`, `my.dev`, `my.apps`) are declared in `options/default.nix` and imported on both sides. NixOS-only switches are declared next to their modules in `os/`. On NixOS, `nixosModules.home` forwards the shared switches to the user's home-manager configuration; `home/` never reads `osConfig`.
- New `my.*` options exist only for switches and for values with no standard option. A machine sets values through the standard option (`nix.settings.max-jobs`, `services.openssh.hostKeys`, `services.postgresql.dataDir`).
- Core settings a machine may want different are `lib.mkDefault` defaults in the shared module (time zone, locale, console font and keyboard in `os/base.nix` and `os/gui/kde.nix`; journald limits and zram in `os/system.nix`); a machine overrides only what differs.

### Hosts and platforms

- A NixOS host imports `nixosModules.default` (every switchable module) and `nixosModules.linux`, plus its own files. Home-manager is opt-in: a host that wants it imports `nixosModules.home` and passes `home-manager = true` to `mkLinuxSystem`; a server does neither.
- User packages are the same on every machine of a platform. The bundles in `home/default.nix` hold what differs: `common-linux` (switches come from the NixOS host), `common-darwin` and `common-wsl` (set their own switches with `lib.mkDefault`, so a host can still override them).
- WSL has no GUI: `common-wsl` turns `my.apps` and `my.tools.hardware` off.

### CLI and GUI

- `home/apps/` holds GUI applications only, each module behind `my.apps.<name>`. `home/development/` and `home/tools/` hold CLI tools only.
- A package that always builds a GUI (heaptrack, for example) belongs in `home/apps/`, even when it also ships CLI tools. Settings that only make sense with a GUI (the default browser, MIME handlers) are gated on the app switch that installs the GUI, not only on the platform.

### Exceptions

User or site values deliberately left in `os/`:
- `os/servers/lldap.nix`: `dc=brcha,dc=com`, `admin@brcha.com` and a plaintext test password. LLDAP is off everywhere; before deploying it, move the password to sops with a newly generated one.
- The `brcha-password` secret name in `os/sops.nix` and `os/users.nix` (waits for the secrets split, issue #5).
- The `brcha-` prefix of the boot entry tag in `os/base.nix` (kept on purpose).
- The age key path `/nix/secret/keys.txt` in `os/sops.nix` (retired with the secrets split, issue #5).
- The tailnet search domain `polecat-grue.ts.net` in `os/servers/tailscale.nix` (one tailnet for all hosts).
- The PostgreSQL roles and databases `finland` and `salmonquail`, with `trust` authentication for local connections, in `os/servers/postgresql.nix`; and the SalmonQuail ports and virtual hosts in `os/servers/salmonquail.nix`. Both are development setups, off everywhere.
- The `.home` virtual host names in `os/gui/torrents.nix`, `os/servers/syncthing.nix` and `os/servers/lldap.nix` (the owner's local naming scheme).
- The Samsung printer driver in `os/hardware/printing.nix`.
- wuwei's values for services it keeps off (PostgreSQL data directory, Ollama home and package) live in `machines/wuwei/servers.nix`.

## Build/Lint/Test Commands

### Primary Commands (using Justfile)
```bash
just fmt                    # Format code with treefmt (nixpkgs-fmt)
just check                  # Run nix flake check: formatting, evaluation tests, Darwin home evaluation, WSL home build
just build                  # Build configuration without applying
just trace                  # Build with full error traces
just neutral [host] [rev]   # Print the system derivation path with the git revision neutralised
just platformcheck          # Evaluate the Darwin and WSL homes only (quick)
just vmtest                 # Run the VM integration tests (slow, needs KVM)
just switch                 # Apply configuration to system (requires sudo)
just test                   # Activate configuration without making it the boot default (requires sudo)
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
The evaluation tests are described under Testing Strategy. To check individual options or modules by hand:
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
    auto-optimise-store = true;
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
GTK_USE_PORTAL = "1"; # to make Firefox-based browsers use KDE's file dialogs

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
A switchable NixOS module declares its switch and wraps its whole configuration in it:
```nix
{ lib, config, ... }:

{
  options.my.servers.redis.enable = lib.mkEnableOption "Redis";

  config = lib.mkIf config.my.servers.redis.enable {
    services.redis.servers."" = { enable = true; };
  };
}
```

A home module uses a switch declared in `options/default.nix`, and guards Linux-only packages:
```nix
{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.graphics {
    home.packages = available (with pkgs; [ gimp inkscape ])
      # Animation; the nixpkgs build fails on macOS, so Linux only for now
      ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.synfigstudio ];
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
      ./os/gui
      ./home
      ./tests
    ];
  }
);
```

### Home-Manager Integration
`nixosModules.home` (in `os/default.nix`) wires the user's home and forwards the shared switches:
```nix
home-manager.users.${config.people.me} = {
  imports = [
    self.homeModules.common-linux
  ];
  my = { inherit (config.my) hyprland kde tools dev apps; };
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
4. Put the module behind a `my.*` switch (see Architecture) and add it to its directory's aggregator; the machine turns it on
5. Keep machine values out of `os/` and `home/`: set them in `machines/<host>/` or `users/`

#### Home-Manager Module Conventions
- `home/` is organized into three subdirectories, each with a `default.nix` aggregator:
  - `home/development/` — language toolchains and dev CLIs (switches `my.dev.<name>`)
  - `home/apps/` — GUI applications (switches `my.apps.<name>`)
  - `home/tools/` — CLI utilities, shell, system tools, networking, documents (always on, except `hardware.nix`)
- `home/default.nix` imports `./development`, `./apps`, and `./tools` as directories
- To add a new home-manager module: create the `.nix` file in the appropriate subdirectory, add it to that subdirectory's `default.nix`, and add its switch to the group's children in `options/default.nix`
- `home/default.nix` itself should not need to change when adding new modules
- Run `just check` after adding packages: it builds the WSL home and evaluates the Darwin home, and CI builds the Darwin home on macOS. Wrap package lists in `available` (drops packages nixpkgs does not offer or marks broken on the platform); packages with hidden Linux-only dependencies or Darwin build failures need an explicit `lib.optionals pkgs.stdenv.isLinux` list with a comment giving the reason

### Package Management
- Use `with pkgs;` for package lists in home-manager
- Prefer unstable packages via `pkgs.unstable.package-name`
- Handle platform-specific packages with conditionals

### Git Workflow
- Feature branches for major changes
- Use `git town sync` (available via `just sync`)
- Commit flake.lock updates with standardized message: "build: update flake inputs"

## Important Notes

- **State Version**: `system.stateVersion` stays at the value the machine was installed with (`"22.05"` on wuwei). Do not bump it: it changes stateful defaults (data formats, paths) and is not an upgrade switch. Change it only after reading the release notes for every version in between
- **Build limits**: per machine in `machines/<host>/default.nix` (`nix.settings`; wuwei: `max-jobs = 16`, `cores = 2`)
- **Secrets**: All sensitive data managed via SOPS in `secrets/` directory
- **Modularization**: `home/` is fully modularized into `development/`, `apps/`, and `tools/` subdirectories — keep it that way

## Testing Strategy

- Validate flake structure: `just check`. It runs `checks.eval` (the evaluation tests), `treefmt`, `darwin-home` (evaluates the Darwin home) and `wsl-home` (builds the WSL home, so it is slow after home changes). `just platformcheck` evaluates both homes without building
- Test builds before applying: `just build` or `just trace`
- Use `nix eval` for specific option testing
- Refactors that should not change the system: compare `just neutral wuwei HEAD` (baseline) with `just neutral` (working tree); the paths must be equal. The working tree evaluation sees changes to tracked files only, so `git add` new files first
- Order-only differences (a reordered package list changes the path, not the system): show them with `nix-diff --skip-already-compared` on the two derivations. For reordered home packages, build `nixosConfigurations.wuwei.config.home-manager.users.brcha.home.path` at both revisions and compare `find . -printf '%P -> %l\n' | sort` listings; identical listings mean an identical profile. Name the difference in the commit body
- Evaluation tests live in `tests/default.nix`: add `testName = { expr = ...; expected = ...; };` to the `tests` set (run with `lib.runTests`). Test hosts come from `tests/lib.nix`: `bare` and `bareWith [ modules ]` (default + linux + a stub), `withHomeWith [ modules ]` (adds home-manager). Read option values rather than forcing `toplevel`, to keep `just check` fast
- `just vmtest` boots two VMs (`tests/vm-ssh.nix`): SSH works and the firewall drops a port it does not open. Run it after firewall or SSH changes
- `tests/platforms.nix` builds the Darwin and WSL homes as standalone home-manager configurations (`flake.platformHomes`)
- CI: `.github/workflows/check.yml` runs `nix flake check` and builds the Darwin home on a macOS runner (`--keep-going`, so one run lists every failure) on every push and pull request; the VM tests run there only when the workflow is started by hand
- Secrets validation: `sops --encrypt --in-place secrets/file.yaml`

Remember: This is a NixOS configuration - changes affect the entire system. Always build and test before switching!