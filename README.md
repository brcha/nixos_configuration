This repository contains my configuration for NixOS and home manager. This is a complete rewrite of the previous config which mixed flakes and legacy code, and also had some leaked secrets (it's a private repo).

## Directory structure

- machines/ — contains root definitions of various machines (currently only one)
- users/ — contains definitions for users
- os/ — contains modules for the NixOS
- home/ — contains modules for the home-manager

## Changes from original configuration

- migrate secrets to [sops-nix](https://github.com/Mic92/sops-nix)
- strip down packages to bare minimum, since I use devshells for development anyway
- move all non-essential packages to home manager

## Creating host keys

```
# ssh-keygen -t ed25519 -N "" -f /persist/etc/ssh/ssh_host_ed25519_key -C "host_yourhostname_2000-00-00"
# ssh-keygen -t ed25519 -N "" -f /persist/etc/ssh/ssh_boot_ed25519_key -C "boot_yourhostname_2000-00-00"
```

## Thanks

- [Nikolas Lenz's config](https://git.eisfunke.com/config/nixos)
- [Sridhar Ratnakumar's config](https://github.com/srid/nixos-config)
