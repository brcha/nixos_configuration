# AGENTS.md — os/

## What This Directory Is

The NixOS system-level configuration layer: modules that do not depend on a machine. Manages system services, hardware support, networking, security, virtualisation, and the GUI environment. Machine values (paths, interface names, build limits, which switches are on) belong in `machines/<host>/`, not here.

## Subpart Documentation

- [`gui/AGENTS.md`](gui/AGENTS.md) — GUI environment modules (KDE Plasma, Hyprland, fonts, Flatpak, SSH agent, torrents)
- [`servers/AGENTS.md`](servers/AGENTS.md) — system service modules (databases, VPN, sync, AI, etc.)

## Structure

`default.nix` defines the NixOS modules a host imports:
- `nixosModules.common` (core) — `../options`, `sops.nix`, `nix.nix`, `users.nix`, `zsh.nix`
- `nixosModules.linux` (core) — `base.nix`, `dns.nix`, `firewall.nix`, `openssh.nix`, `system.nix`
- `nixosModules.hardware`, `nixosModules.virtualisation`, `nixosModules.servers` — the switchable groups below
- `nixosModules.home` — opt-in home-manager: imports the home-manager NixOS module, gives the user `homeModules.common-linux` and forwards the shared switches (`my.hyprland`, `my.kde`, `my.tools`, `my.dev`, `my.apps`)
- `nixosModules.default` — `common` plus every switchable module (`gui`, `kde`, `hyprland` from `gui/default.nix`, `hardware`, `virtualisation`, `servers`). It does not include `linux` or `home`; a host imports those itself

Core modules (always on):

- `base.nix` — core system settings: time zone, locale and console font (as `lib.mkDefault` defaults), geolocation, OOM killer, firmware updates, GPG agent, PAM, systemd initrd, boot entry tag
- `dns.nix` — SmartDNS on `127.0.0.1` with racing upstream resolvers; owns `networking.nameservers = [ "127.0.0.1" ]` and routes every name to it (resolved `Domains = ~.`)
- `firewall.nix` — firewalld on nftables and the shared zones (`internal`: target ACCEPT, forwarding on). Services only add their interfaces or ports
- `nix.nix` — Nix daemon configuration: nixpkgs settings (allowUnfree, the `unstable` overlay), registry, store optimisation, GC, trusted users
- `openssh.nix` — OpenSSH server; the host key path is a default a machine overrides
- `sops.nix` — SOPS system-level secrets configuration
- `system.nix` — journald limits and zram (as `lib.mkDefault` defaults); ZFS scrub and trim when the machine uses ZFS
- `users.nix` — the user from `flake.config.people.me` and generic groups
- `zsh.nix` — system-wide zsh enablement

Switchable groups:

- `hardware/` — `printing.nix` (CUPS), `sound.nix` (PipeWire), `razer.nix` (openrazer); `my.hardware.<name>.enable`, each independent of the GUI
- `virtualisation/default.nix` — Docker and VMware (`my.virtualisation.enable` and its children `docker`, `vmware`) and VirtualBox (`my.virtualisation.virtualbox`, off unless set); adds the user to the `docker` and `vboxusers` groups when on
- `gui/` — see [`gui/AGENTS.md`](gui/AGENTS.md)
- `servers/` — see [`servers/AGENTS.md`](servers/AGENTS.md)

## Conventions

- Module signature: `{ pkgs, lib, config, flake, ... }:` — include only what is needed
- A switchable module declares `options.my.<group>.<name>.enable` (or its group with `lib/group.nix`) next to its code and wraps its configuration in `lib.mkIf`
- System services belong here; user-space packages belong in `home/`
- No machine values here: a machine sets them through the standard option in `machines/<host>/`. Settings a machine may want different are `lib.mkDefault` defaults
- A service configures only its own service. Shared concerns (firewall zones, nameservers) live in their own module; vendor groups (`docker`, `vboxusers`, `openrazer`) are added by the module that owns them

## Important Notes

- `nix.nix` applies the `unstable` overlay globally via `nixpkgs.overlays`
- Build limits (`nix.settings.max-jobs`, `cores`) are set per machine, not here
- Hardware-dependent home-manager modules (openrazer, steam, etc.) require corresponding NixOS enablement here
- User or site values that remain here on purpose are listed in the root `AGENTS.md` (Architecture, Exceptions)
