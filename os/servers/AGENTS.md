# AGENTS.md — os/servers/

## What This Directory Is

NixOS modules for system-level services and daemons. Each file configures one service behind its own switch, `my.servers.<name>.enable`, off by default. Every host imports all of them (through `nixosModules.default`); a machine turns on the ones it runs in `machines/<host>/default.nix`.

## Module List

- `avahi.nix` — Avahi mDNS publishing
- `clamav.nix` — ClamAV antivirus daemon, updater and fangfrisch
- `k3s.nix` — k3s lightweight Kubernetes
- `lldap.nix` — LLDAP lightweight LDAP server (test configuration, see Important Notes)
- `ollama.nix` — Ollama local LLM inference server
- `postgresql.nix` — PostgreSQL database server with PostGIS and extensions
- `redis.nix` — Redis in-memory data store
- `salmonquail.nix` — ports and nginx virtual hosts for the SalmonQuail development project
- `syncthing.nix` — Syncthing continuous file synchronisation
- `tailscale.nix` — Tailscale VPN daemon; adds `tailscale0` to the firewalld `internal` zone
- `teamviewer.nix` — TeamViewer remote desktop daemon
- `tor.nix` — Tor client with DNS, and privoxy

## Architecture

- `default.nix` imports every module; `nixosModules.servers` (part of `nixosModules.default`) exposes them
- Each module is self-contained and configures exactly one service
- Modules that are off everywhere must still evaluate: the evaluation tests turn every switch on

## Conventions

- Declare `options.my.servers.<name>.enable = lib.mkEnableOption "...";` and wrap the configuration in `config = lib.mkIf config.my.servers.<name>.enable { ... };`
- Use the NixOS defaults for paths and packages; a machine sets its own values through the standard options (wuwei's are in `machines/wuwei/servers.nix`)
- A service opens its own ports and adds itself to an existing firewall zone; it does not define zones
- Secrets (passwords, tokens) must use SOPS — never hardcode credentials. Exception: the LLDAP test password, see below
- When adding a module, add it to `default.nix`

## Important Notes

- `lldap.nix` holds a plaintext test password and the owner's domain. LLDAP is off everywhere; before deploying it, move the password to sops with a newly generated one and keep it in the password manager for the admin panel
- Services that have a home-manager counterpart (e.g., syncthing, tailscale) should keep system config here and user config in `home/`
