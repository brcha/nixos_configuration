# Plan: Modularize `home/therest_to_be_modularized.nix`

## Goal

Split the monolithic `home/therest_to_be_modularized.nix` (~320 lines, ~150 packages) into
fine-grained, single-responsibility modules organized under subdirectories that mirror the
existing `os/gui/` and `os/servers/` patterns. Deduplicate packages already declared in
existing modules. Delete the original file once all packages are redistributed.

---

## Context & Constraints

- Framework: flake-parts + nixos-unified + home-manager
- Existing home modules: `shell.nix`, `git.nix`, `neovim.nix`, `kde.nix`, `firefox.nix`,
  `sops.nix`, `development/python.nix`, `development/rust.nix`
- `home/development/rust.nix` currently only has `sccache`; Rust packages from the monolith
  will be merged into it
- All packages in the monolith are `home.packages` — none need to move to `os/`
- Code style: 2-space indent, `with pkgs;` for package lists, `{ pkgs, lib, ... }:` signature
- Imports are wired through `home/default.nix` → `homeModules.common`

---

## Proposed File Structure

```
home/
├── default.nix                        (imports: sops, development, apps, tools)
├── sops.nix
├── development/
│   ├── default.nix                    (aggregates all development modules)
│   ├── ai.nix
│   ├── cpp.nix
│   ├── databases.nix
│   ├── devops.nix
│   ├── git.nix                        (moved from home/git.nix)
│   ├── git-tools.nix
│   ├── go.nix
│   ├── haskell.nix
│   ├── jetbrains.nix
│   ├── neovim.nix                     (moved from home/neovim.nix)
│   ├── python.nix
│   ├── rust.nix
│   ├── tools.nix
│   ├── vcs.nix
│   └── web.nix
├── apps/
│   ├── default.nix                    (aggregates all apps modules)
│   ├── cloud-storage.nix
│   ├── communication.nix
│   ├── firefox.nix                    (moved from home/firefox.nix)
│   ├── gaming.nix
│   ├── graphics.nix
│   ├── kde.nix                        (moved from home/kde.nix)
│   ├── multimedia.nix
│   ├── productivity.nix
│   └── security.nix
└── tools/
    ├── default.nix                    (aggregates all tools modules)
    ├── cli.nix
    ├── compression.nix
    ├── documents.nix
    ├── networking.nix
    ├── shell.nix                      (moved from home/shell.nix)
    └── system.nix
```

---

## Package → Module Mapping

### `development/rust.nix` (extend existing)
Merge in from monolith:
- `rustup`, `cargo-generate`, `cargo-edit`, `cargo-watch`, `wasm-pack`
- `cargo-features-manager`, `cargo-expand`, `cargo-outdated`, `cargo-tauri`, `cargo-mobile2`
- `perseus-cli`, `trunk`, `diesel-cli`
- `hyperfine` (benchmarking, Rust-adjacent)

Already in `rust.nix`: `sccache` — keep.

### `development/haskell.nix` (new)
- `ghc`, `stack`

### `development/go.nix` (new)
- `go`, `gotools`

### `development/cpp.nix` (new)
- `cmake`, `cmake-format`, `ninja`
- `clang_20`, `clang-tools`, `clang-analyzer`, `ccls`
- `gdb`, `lldb`, `valgrind`
- `kdePackages.kcachegrind`, `massif-visualizer`, `heaptrack`
- `whatstyle`, `pkg-config`
- `kdiff3`, `meld`

### `development/web.nix` (new)
- `nodejs`, `nodePackages.yarn`, `nodePackages.prettier`
- `nodePackages.vercel`, `heroku`
- `hugo` (static site)
- `wasm-pack`, `trunk` (also Rust/WASM — cross-listed; keep in rust.nix, omit here)

> **Note:** `wasm-pack` and `trunk` are already in `rust.nix` above; do not duplicate.
> **Note:** `ngrok` moves to `tools/networking.nix` — it is a general tunnelling tool, not web-specific.

### `development/git-tools.nix` (new)
- `git-town`, `delta`, `git-ignore`, `git-absorb`
- `git-cliff`, `git-standup`, `gitflow`, `gitleaks`
- `pre-commit`, `commitizen`
- `qgit`, `thicket`, `git-subrepo`
- `gist`
- `github-cli`, `glab`

### `development/vcs.nix` (new)
Non-git version control systems:
- `mercurial`, `darcs`, `pijul`, `subversion`

### `development/devops.nix` (new)
- `doctl`, `caddy`, `devbox`, `devenv`
- `kubernetes-helm`, `terraform`, `unstable.pulumi`, `k9s`

### `development/databases.nix` (new)
- `sqlite`
- `pgmanage`, `dbeaver-bin`
- `diesel-cli` is already in `rust.nix` above — omit here

### `development/jetbrains.nix` (new)
- `jetbrains.clion`, `jetbrains.goland`, `jetbrains.pycharm`
- `jetbrains.rust-rover`, `jetbrains.datagrip`, `jetbrains.webstorm`

### `development/tools.nix` (new)
Developer-facing documentation, analysis, and formatting tools that don't belong to a single language:
- `doxygen`, `graphviz` (code/architecture documentation)
- `plantuml` (diagram generation)
- `loccount` (source line counting)
- `cmake-format`, `whatstyle` (code formatting tools, C++ adjacent but language-agnostic)
- `nixpkgs-fmt` (Nix formatter)
- `shfmt` (shell formatter)
- `fantomas` (F# formatter)
- `stylelint` (CSS/SCSS linter-formatter)

### `development/ai.nix` (new)
- `unstable.claude-code` (Anthropic CLI coding assistant)
- `claude-desktop.claude-desktop-fhs` (Anthropic desktop app)
- `unstable.opencode` (OpenCode AI coding assistant)
- `unstable.zed-editor` (AI-native editor)

### `apps/productivity.nix` (new)
- `zeal` (offline docs browser)
- `joplin-desktop`
- `clockify`, `wakatime-cli`
- `hledger`, `hledger-ui`, `hledger-web`, `hledger-interest`
- `libreoffice-qt`
- `html2text`

### `apps/multimedia.nix` (new)
- `smplayer`, `mpv`, `vlc`
- `yt-dlp`, `mkvtoolnix`
- `frei0r`, `ffmpeg-full`
- `spotify`
- `qpwgraph`
- `kdePackages.kdenlive`, `avidemux`
- `obs-studio`
- `lmms`

### `apps/graphics.nix` (new)
- `gimp`, `krita`, `inkscape`
- `povray`, `scribus`
- `synfigstudio`
- `sweethome3d.application`, `sweethome3d.textures-editor`, `sweethome3d.furniture-editor`
- `imagemagick`

### `apps/gaming.nix` (new)
- `steam` (with override + extraPkgs)
- `steam.run` (with same override)
- `protontricks`

### `apps/cloud-storage.nix` (new)
- `yandex-disk`, `megasync`
- `onedrive`, `onedrivegui`
- `dropbox`

### `apps/communication.nix` (new)
- `telegram-desktop`, `discord`
- `unstable.zoom-us`

### `apps/security.nix` (new)
- `tor-browser`, `diceware`
- `qtpass`, `gopass`, `gopass-jsonapi`
- `clamav`, `clamtk`
- `signing-party`, `openssl`, `gnupg`
- `pcsc-tools`, `pcsclite`

### `tools/cli.nix` (new)
- `bat`, `fd`, `fzf`, `jq`, `yq-go`
- `neofetch`, `fastfetch`, `htop`, `cheat`
- `just`
- `tree`, `mc`, `lsof`
- `skim`, `csvtool`
- `httpie`
- `lesspipe`
- `uutils-coreutils-noprefix`
- `unstable.asdf-vm`

### `tools/compression.nix` (new)
- `lrzip`, `zip`, `unzip`, `unrar`
- `xar`, `lz4`, `lzop`, `rzip`, `upx`
- `xdelta`, `zstd`, `zsync`, `p7zip`, `zpaq`
- `brotli`, `lzip`, `squashfsTools`

### `tools/networking.nix` (new)
- `nmap`, `rustscan`
- `wireguard-tools` (deduplicate — appears twice in monolith)
- `protonvpn-gui`, `protonmail-bridge-gui`
- `strongswanNM`
- `aria2`, `persepolis`
- `socat`
- `wget`, `inetutils`, `dig`
- `can-utils`, `cantoolz`
- `unstable.bootiso`
- `ngrok` (general TCP/HTTP tunnelling tool)
- `ktailctl` (KDE GUI for Tailscale)

### `tools/system.nix` (new)
- `usbutils`, `cpufrequtils`, `psmisc`, `file`
- `lm_sensors`, `pciutils`, `lshw`, `hwinfo`
- `lsb-release`, `geoipWithDatabase`
- `sysstat`, `smartmontools`, `msr-tools`, `hddtemp`
- `xorg.xev`, `xorg.xwininfo`, `xorg.xhost`, `xorg.xdpyinfo`
- `mesa-demos`, `clinfo`, `vulkan-tools`, `wayland-utils`
- `ntfs3g`, `exfat`, `dosfstools`
- `btrfs-progs`, `zfs`, `zfs-replicate`, `sanoid`, `znapzend`, `vorta`
- `fpart`, `parted`, `gptfdisk`
- `appimage-run`
- `openrazer-daemon`, `razergenie`
- `mkpasswd`, `pwgen`
- `python312Packages.xattr`, `pxattr`
- `unstable.cachix`
- `nox`

### `tools/documents.nix` (new)
- `texlive.combined.scheme-full`, `rubber`
- `pandoc`, `pdftk`
- `bibtex-tidy` (BibTeX formatter, document-adjacent)

> **Note:** `doxygen`, `graphviz`, and `plantuml` move to `development/tools.nix` — they are
> developer documentation generators, not general document processing tools.

---

## Steps

### Step 1 — Create `home/development/haskell.nix`
- `{ pkgs, ... }: { home.packages = with pkgs; [ ghc stack ]; }`

### Step 2 — Create `home/development/go.nix`
- `{ pkgs, ... }: { home.packages = with pkgs; [ go gotools ]; }`

### Step 3 — Create `home/development/cpp.nix`
- cmake, ninja, clang toolchain, debuggers, profilers, diff tools, pkg-config

### Step 4 — Create `home/development/web.nix`
- nodejs, yarn, prettier, vercel, heroku, hugo

### Step 5 — Create `home/development/git-tools.nix`
- Git ecosystem packages (commit helpers, review tools, forge CLIs, git-adjacent utilities)

### Step 5b — Create `home/development/vcs.nix`
- Non-git VCS: mercurial, darcs, pijul, subversion

### Step 6 — Create `home/development/devops.nix`
- Cloud CLIs, IaC tools, container/k8s tools

### Step 7 — Create `home/development/databases.nix`
- sqlite, pgmanage, dbeaver-bin

### Step 8 — Create `home/development/jetbrains.nix`
- All JetBrains IDEs as a single cohesive module

### Step 9 — Create `home/development/ai.nix`
- claude-desktop, claude-code, opencode, zed-editor

### Step 10 — Create `home/development/tools.nix`
- doxygen, graphviz, plantuml, loccount, cmake-format, whatstyle
- nixpkgs-fmt, shfmt, fantomas, stylelint (language-agnostic formatters/linters)

### Step 11 — Extend `home/development/rust.nix`
- Merge all Rust/cargo packages from monolith into existing file

### Step 12 — Create `home/apps/productivity.nix`
- Notes (Joplin), time tracking, finance, office

### Step 13 — Create `home/apps/multimedia.nix`
- Video players, audio (incl. lmms), streaming, video editing

### Step 14 — Create `home/apps/graphics.nix`
- Raster/vector editors, 3D, animation, image processing

### Step 15 — Create `home/apps/gaming.nix`
- Steam (with override), protontricks

### Step 16 — Create `home/apps/cloud-storage.nix`
- Cloud sync clients

### Step 17 — Create `home/apps/communication.nix`
- Messaging and video conferencing

### Step 18 — Create `home/apps/security.nix`
- Password managers, VPN, antivirus, crypto tools, smart card

### Step 19 — Create `home/tools/cli.nix`
- CLI utilities and shell helpers (bat, fd, fzf, jq, htop, httpie, etc.), asdf-vm

### Step 20 — Create `home/tools/compression.nix`
- Archive and compression tools

### Step 21 — Create `home/tools/networking.nix`
- Network scanners, VPN clients, download managers, ngrok, ktailctl

### Step 22 — Create `home/tools/system.nix`
- Hardware info, filesystem tools, display utilities, storage management

### Step 23 — Create `home/tools/documents.nix`
- LaTeX, document converters (pandoc, pdftk, rubber), bibtex-tidy

### Step 24 — Update `home/default.nix`
Replace the single `./therest_to_be_modularized.nix` import with all new module paths:
```nix
# development
./development/haskell.nix
./development/go.nix
./development/cpp.nix
./development/web.nix
./development/git-tools.nix
./development/vcs.nix
./development/devops.nix
./development/databases.nix
./development/jetbrains.nix
./development/ai.nix
./development/tools.nix
# apps
./apps/productivity.nix
./apps/multimedia.nix
./apps/graphics.nix
./apps/gaming.nix
./apps/cloud-storage.nix
./apps/communication.nix
./apps/security.nix
# tools
./tools/cli.nix
./tools/compression.nix
./tools/networking.nix
./tools/system.nix
./tools/documents.nix
```

### Step 25 — Delete `home/therest_to_be_modularized.nix`

### Step 26 — Add `default.nix` aggregators to each subdirectory
- Create `home/development/default.nix` importing all development modules
- Create `home/apps/default.nix` importing all apps modules
- Create `home/tools/default.nix` importing all tools modules
- Simplify `home/default.nix` to import `./development`, `./apps`, `./tools` instead of individual files

### Step 27 — Relocate pre-existing root-level modules into subdirectories
Move files that were already in `home/` before this work into their logical subdirectory:
- `home/git.nix` → `home/development/git.nix` (add to `development/default.nix`)
- `home/shell.nix` → `home/tools/shell.nix` (add to `tools/default.nix`)
- `home/firefox.nix` → `home/apps/firefox.nix` (add to `apps/default.nix`)
- `home/neovim.nix` → `home/development/neovim.nix` (add to `development/default.nix`)
- `home/kde.nix` → `home/apps/kde.nix` (add to `apps/default.nix`)
- Remove the now-redundant explicit imports from `home/default.nix`

### Step 28 — Create AGENTS.md files for home subdirectories
- `home/development/AGENTS.md` — document purpose, module list, conventions
- `home/apps/AGENTS.md` — document purpose, module list, conventions
- `home/tools/AGENTS.md` — document purpose, module list, conventions

### Step 28b — Create AGENTS.md for home/ and os/ layers
- `home/AGENTS.md` — document home-manager layer structure, subdirectory references, conventions
- `os/AGENTS.md` — document NixOS system layer structure, flat modules, subdirectory references
- `os/gui/AGENTS.md` — document GUI environment modules (KDE, fonts, Flatpak, Hyprland)
- `os/servers/AGENTS.md` — document system service modules (one service per file pattern)

### Step 28c — Update root AGENTS.md
- Add `home/AGENTS.md` and `os/AGENTS.md` (and their subdirs) to the Subpart Documentation section

### Step 29 — Validate
```bash
just check    # nix flake check
just build    # build without applying
```

---

## Deduplication Notes

| Package | Current location | Action |
|---|---|---|
| `rustup`, `cargo-*`, `trunk`, `wasm-pack`, `diesel-cli` | monolith | Move to `development/rust.nix` |
| `sccache` | `development/rust.nix` | Keep, no change |
| `wireguard-tools` | monolith (×2) | Deduplicate → single entry in `tools/networking.nix` |
| `fzf` | monolith (×2) | Deduplicate → single entry in `tools/cli.nix` |
| `python3.*` | `development/python.nix` | No overlap in monolith; keep as-is |

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| `steam` override uses a closure `pkgs:` — must be preserved verbatim | Copy the full override block into `apps/gaming.nix` |
| `unstable.*` packages require `pkgs.unstable` overlay to be active | Already wired via `flake.overlays.unstable`; no change needed |
| `claude-desktop.claude-desktop-fhs` uses a custom overlay attribute | Already in `flake.overlays.unstable`; just reference it normally |
| `texlive.combined.scheme-full` is very large — build time unchanged | No risk, just a note |
| Missing `flake` argument in new modules | New modules only need `{ pkgs, ... }:` unless they reference `flake.config` |
| `just check` may catch attribute errors in new files | Run after each batch of files, not just at the end |

---

## Open Questions

All previously open questions have been resolved by Master:

| Item | Decision |
|---|---|
| `lmms` | `apps/multimedia.nix` |
| `doxygen` | `development/tools.nix` (along with `graphviz`, `plantuml`) |
| `ngrok` | `tools/networking.nix` |
| JetBrains IDEs | `development/jetbrains.nix` (own module, not split further) |
| `unstable.asdf-vm` | `tools/cli.nix` |

No open questions remain.

---

## AGENTS.md Impact

The following new home-manager subdirectory conventions are now established and should be documented in AGENTS.md:
- `home/development/` — language toolchains, editors, IDEs, VCS, dev tools, formatters
- `home/apps/` — end-user GUI applications (browser, mail, media, games, etc.)
- `home/tools/` — CLI utilities, system tools, shell, networking, documents
- Each subdirectory has a `default.nix` aggregator; `home/default.nix` imports directories, not individual files
- New modules in a category: add the file and add it to the subdirectory's `default.nix` only
