# Plan: Add rtm Packages to home/apps/productivity.nix

## Goal

Integrate `rtmcli` and `rtmapp` from `github:brcha/rtm` into the NixOS home-manager configuration, following the established overlay pattern used for `claude-desktop`.

## Context & Constraints

- **Branch**: `main` (no branch prefix in filename per convention)
- **rtm flake**: `github:brcha/rtm` exposes `packages.${system}.rtmcli`, `packages.${system}.rtmapp`, and `packages.${system}.rtmgui` — we include only `rtmcli` and `rtmapp`, skipping `rtmgui`
- **Established pattern**: External flake packages are injected via `flake.overlays.unstable` in `flake.nix`, then consumed as `pkgs.<overlay-name>.<package>` in home-manager modules (see `claude-desktop` as the reference implementation)
- **Target module**: `home/apps/productivity.nix` — rtm is a productivity tool (todo.txt manager)
- **Module signature**: `{ pkgs, ... }:` — no `flake` argument needed since packages arrive via the overlay
- **No new module file needed**: rtm packages fit naturally into the existing `productivity.nix`

## Steps

### 1. Add `rtm` input to `flake.nix`

In the `inputs` block, add:

```nix
rtm = {
  url = "github:brcha/rtm";
};
```

Place it near `claude-desktop` (other external app flakes), after line 14.

**Acceptance criteria**: `nix flake show` lists `rtm` as an input.

---

### 2. Expose rtm packages via the overlay in `flake.nix`

In `flake.overlays.unstable` (around line 89), add an `rtm` attribute alongside `claude-desktop`:

```nix
rtm = inputs.rtm.packages.${prev.stdenv.hostPlatform.system};
```

Full overlay block after change:

```nix
flake.overlays.unstable = (final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config = prev.config;
  };
  claude-desktop = inputs.claude-desktop.packages.${prev.stdenv.hostPlatform.system};
  rtm = inputs.rtm.packages.${prev.stdenv.hostPlatform.system};
  jackett = prev.jackett.overrideAttrs (_oldAttrs: {
    doCheck = false;
  });
});
```

**Acceptance criteria**: `nix eval .#overlays.unstable` (or `nix flake check`) does not error; `pkgs.rtm` is accessible in modules.

---

### 3. Add `rtmcli` and `rtmapp` to `home/apps/productivity.nix`

Append to the `home.packages` list with a `# Todo.txt manager` comment group:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Documentation browser
    zeal

    # Notes
    joplin-desktop

    # Time tracking
    clockify
    wakatime-cli

    # Finance
    hledger
    hledger-interest
    hledger-ui
    hledger-web

    # Office suite
    libreoffice-qt

    # Document conversion
    html2text

    # Todo.txt manager
    rtm.rtmcli
    rtm.rtmapp
  ];
}
```

Note: `with pkgs;` makes `rtm` resolve to `pkgs.rtm`, so `rtm.rtmcli` and `rtm.rtmapp` are attribute selections on the overlay-injected attrset.

**Acceptance criteria**: File is syntactically valid Nix; `nix eval` on the home config resolves the packages without error.

---

### 4. Validate and build

```bash
just fmt        # Format with nixpkgs-fmt
just check      # nix flake check — validates flake structure
just build      # Build the full system configuration
```

Fix any errors before proceeding to `just switch`.

**Acceptance criteria**: All three commands complete without errors.

---

### 5. (Optional) Update `home/apps/AGENTS.md`

Update the `productivity.nix` entry in the Module List section to mention rtm:

```
- `productivity.nix` — Productivity apps (joplin, clockify, wakatime, hledger, libreoffice, zeal, rtm)
```

**Acceptance criteria**: AGENTS.md accurately reflects the module contents.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `rtm` flake uses `flake-utils.lib.eachDefaultSystem` — packages are keyed by system string | Low | The overlay pattern `inputs.rtm.packages.${prev.stdenv.hostPlatform.system}` handles this correctly, same as `claude-desktop` |
| `rtmapp` (Tauri/WebKitGTK) may fail to build due to missing system deps | Medium | `rtmapp` requires `webkitgtk_4_1` and `libsoup_3` at build time; these are declared as `buildInputs` in the rtm flake itself so the Nix build should be self-contained. If it fails, fall back to `rtmcli` only and file an issue upstream. |
| `flake.lock` will need updating | Certain | Run `nix flake update rtm` (or `just update`) after adding the input to fetch and pin the lock entry |
| `with pkgs;` scope: `rtm.rtmcli` is an attrset selection, not a package name — this is valid Nix | Low | Confirmed by the `claude-desktop.claude-desktop-fhs` precedent in `home/development/ai.nix` |

## Open Questions

1. **`rtmapp` stability**: The rtm flake marks `rtmapp` as "best-effort" (bypasses Tauri bundler). Should we include it unconditionally or guard it? → Proceed with inclusion; if the build fails, remove it and note the issue.
2. **`flake-utils` input pinning**: `rtm` depends on `flake-utils` independently. No `follows` override is needed unless input deduplication becomes a concern — leave as-is for now.
3. **AGENTS.md update**: Confirm whether Master wants the AGENTS.md update (Step 5) performed as part of this task or deferred.
