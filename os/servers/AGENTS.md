# AGENTS.md — os/servers/

## What This Directory Is

NixOS modules for system-level services and daemons. Each file enables and configures one service. These are opt-in — machines import only the services they need.

## Module List

- `clamav.nix` — ClamAV antivirus daemon and updater
- `k3s.nix` — k3s lightweight Kubernetes
- `lldap.nix` — LLDAP lightweight LDAP server
- `ollama.nix` — Ollama local LLM inference server
- `postgresql.nix` — PostgreSQL database server
- `redis.nix` — Redis in-memory data store
- `salmonquail.nix` — machine-specific or custom service configuration
- `syncthing.nix` — Syncthing continuous file synchronisation
- `tailscale.nix` — Tailscale VPN daemon
- `teamviewer.nix` — TeamViewer remote desktop daemon
- `tor.nix` — Tor anonymity network daemon

## Architecture

- No `default.nix` aggregator — machine configurations import individual service modules directly
- Each module is self-contained and enables exactly one service

## Conventions

- Use `lib.mkIf config.<service>.enable` pattern where the service has a NixOS option
- Secrets (passwords, tokens) must use SOPS — never hardcode credentials
- Machines import individual service modules from `machines/<name>/` — not all services are active on all machines

## Important Notes

- `salmonquail.nix` may contain machine-specific overrides — check before modifying
- Services that have a home-manager counterpart (e.g., syncthing, tailscale) should keep system config here and user config in `home/`
