# AGENTS.md — os/

## What This Directory Is

The NixOS system-level configuration layer. Manages system services, hardware, networking, security, virtualisation, and GUI environment. Organized into a flat set of modules plus two subdirectories (`gui/` and `servers/`).

## Subpart Documentation

- [`gui/AGENTS.md`](gui/AGENTS.md) — GUI environment modules (KDE Plasma, fonts, Flatpak, Hyprland)
- [`servers/AGENTS.md`](servers/AGENTS.md) — system service modules (databases, VPN, sync, AI, etc.)

## Structure

Flat modules:

- `default.nix` — defines `nixosModules.common`, `nixosModules.linux`, `nixosModules.my-config`, `nixosModules.default`
- `base.nix` — core system settings: localization (Europe/Belgrade, sr_RS), console, geolocation, OOM killer, firmware updates, GPG agent, PAM, systemd initrd
- `dns.nix` — DNS: Avahi mDNS, SmartDNS with multiple upstream resolvers
- `nix.nix` — Nix daemon configuration: nixpkgs settings (allowUnfree, overlays), registry, store optimisation, GC, build limits (`max-jobs = 1`, `cores = 4`)
- `openssh.nix` — OpenSSH server configuration
- `printing.nix` — CUPS printing with gutenprint and Samsung drivers
- `sops.nix` — SOPS system-level secrets configuration
- `sound.nix` — PipeWire audio (ALSA, PulseAudio, JACK compatibility)
- `users.nix` — system user definitions
- `virtualisation.nix` — VirtualBox and VMware host configuration
- `zsh.nix` — system-wide zsh enablement

Subdirectories:

- `gui/` — GUI environment modules (KDE Plasma, fonts, Flatpak, Hyprland)
- `servers/` — system service modules (databases, VPN, sync, AI, etc.)

## Conventions

- Module signature: `{ pkgs, lib, config, flake, ... }:` — include only what is needed
- Use `lib.mkIf` for conditional enablement
- System services belong here; user-space packages belong in `home/`
- `nix.nix` contains temporary build constraints (`max-jobs = 1`) due to memory shortage — do not remove without verifying available RAM

## Important Notes

- `base.nix` sets timezone to `Europe/Belgrade` and locale to `C.UTF-8` with `sr_RS` extras
- `nix.nix` applies the `unstable` overlay globally via `nixpkgs.overlays`
- Hardware-dependent home-manager modules (openrazer, steam, etc.) require corresponding NixOS enablement here
