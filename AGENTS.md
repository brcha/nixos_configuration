# AGENTS.md

NixOS and home-manager configuration (a flake). This file and the subpart files list only conventions and constraints; the code shows the rest.

## Subparts

- [`home/AGENTS.md`](home/AGENTS.md) — home-manager layer
- [`home/development/AGENTS.md`](home/development/AGENTS.md) — development tools and Neovim
- [`home/apps/AGENTS.md`](home/apps/AGENTS.md) — GUI applications, Hyprland and Quickshell
- [`home/tools/AGENTS.md`](home/tools/AGENTS.md) — CLI tools and the shell
- [`os/AGENTS.md`](os/AGENTS.md) — NixOS layer
- [`os/gui/AGENTS.md`](os/gui/AGENTS.md) — NixOS GUI modules
- [`os/servers/AGENTS.md`](os/servers/AGENTS.md) — NixOS service modules
- [`doc/hyprland.md`](doc/hyprland.md) — user documentation: the Hyprland keybindings. Update it whenever a bind changes

## Layers and switches

- `os/` and `home/` hold no machine values (paths, interface names, build limits, which switches are on): those go in `machines/<host>/`, set through the standard option.
- Settings a machine may want different are `lib.mkDefault` in the shared module; the machine overrides only what differs.
- Every optional module is behind a `my.*` switch, off by default; the machine turns it on in `machines/<host>/default.nix`.
- A group child defaults to its group switch (`lib/group.nix`); `my.virtualisation.virtualbox` is the exception and stays off unless set.
- Add a `my.*` option only for a switch or for a value with no standard option.
- Shared switches are declared in `options/default.nix` and must be added to the list `nixosModules.home` forwards to home-manager (`os/default.nix`); NixOS-only switches are declared next to their module in `os/`.
- A service module configures only its own service; shared concerns (firewalld zones, nameservers) live in their own `os/` module, and a service only plugs itself in.
- `home/apps/` holds GUI applications only; a package that always builds a GUI goes there even when it also ships CLI tools. `home/development/` and `home/tools/` hold CLI tools only.
- Settings that only make sense with a GUI (default browser, MIME handlers) are gated on the switch of the app that provides the GUI.
- The WSL home gets no GUI applications.
- Secrets go through sops (`secrets/`), never into Nix files.
- Never change `system.stateVersion` or `home.stateVersion`: they change stateful defaults and are not upgrade switches.

## Commands

- `just fmt` formats; `just check` runs the flake checks (formatting, evaluation tests, Darwin and WSL homes, script checks); `just build` builds without activating.
- `just vmtest` (needs KVM) after firewall or SSH changes.
- `just update [inputs...]` updates inputs through its own pull request and must start on a clean `main`.

## Testing

- Flakes see tracked files only: `git add` new files before `just check`, `just build` or `just neutral`.
- Evaluation tests go in `tests/default.nix`, with test hosts from `tests/lib.nix`; read option values instead of forcing `toplevel`, to keep `just check` fast.
- A refactor that should not change the system: `just neutral wuwei HEAD` and `just neutral` must print the same path.
- Order-only differences: show them with `nix-diff --skip-already-compared` (for home packages, compare sorted `find . -printf '%P -> %l\n'` listings of `home.path` at both revisions) and name them in the commit body.

## Git and CI

- `main` takes squash-merged pull requests only; the checks `flake-check` and `platform-macos` must pass.
- The required checks match job names in `.github/workflows/check.yml`: renaming or removing those jobs means updating the "protect main" ruleset.
- Skip a required job with an `if:` on the job, never with workflow `paths` filters: a workflow that does not start never reports its check.
- A file matching the Linux-only pattern in `check.yml` keeps its configuration behind a switch `common-darwin` leaves off, or behind `pkgs.stdenv.isLinux`; otherwise take it out of the pattern.
- If the flake starts reading a file the `changes` job treats as unread, narrow that rule.
- Input updates are committed as `build: update flake inputs`.
