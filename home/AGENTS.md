# AGENTS.md — home/

- Never read `osConfig`: switches arrive as `config.my.*`, and per-user values come from `flake.config.people.users.${config.home.username}`.
- A new module goes into its subdirectory's `default.nix`; in `development/` and `apps/` its switch also goes into the group's children in `options/default.nix`. `home/default.nix` changes only when a platform bundle changes its switches.
- Wrap package lists in `available`; a package it lets through that fails on Darwin goes in a `lib.optionals pkgs.stdenv.isLinux` list with a comment giving the reason. Guard Linux-only settings (`xdg.mime`, user units) the same way.
- Prefer `pkgs.unstable.*` for fast-moving tools (language servers, formatters, AI tools).
- Install only tools used regularly; the rest run on demand with `, <command>`, `nix shell` or a project's dev shell.
- A tool that needs kernel modules, udev rules or a system service also needs its NixOS side in `os/`.
