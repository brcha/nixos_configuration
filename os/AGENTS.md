# AGENTS.md — os/

- `nixosModules.default` holds every switchable module but not `nixosModules.linux` or `nixosModules.home`: a host imports those itself, and a home-manager host also passes `home-manager = true` to `mkLinuxSystem`.
- The module that owns a vendor group (`docker`, `vboxusers`, `openrazer`) adds the user to it.

## Values left here on purpose

- `servers/lldap.nix`: `dc=brcha,dc=com`, `admin@brcha.com` and a plaintext test password. LLDAP is off everywhere; before deploying it, move the password to sops with a newly generated one.
- The `brcha-password` secret name in `sops.nix` and `users.nix` (waits for the secrets split, issue #5).
- The `brcha-` prefix of the boot entry tag in `base.nix`.
- The age key path `/nix/secret/keys.txt` in `sops.nix` (retired with the secrets split, issue #5).
- The tailnet domain `polecat-grue.ts.net` (DNS delegate, search domain and SmartDNS rule) in `servers/tailscale.nix`: one tailnet for all hosts.
- The PostgreSQL roles and databases `finland` and `salmonquail` with local `trust` authentication in `servers/postgresql.nix`, and the SalmonQuail ports and virtual hosts in `servers/salmonquail.nix`: development setups, off everywhere.
- The `.home` virtual host names in `gui/torrents.nix`, `servers/syncthing.nix` and `servers/lldap.nix` (the owner's local naming scheme).
- The Samsung printer driver in `hardware/printing.nix`.
