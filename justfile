default:
    @just --list

fmt:
    treefmt

check:
    nix flake check

# Update flake inputs (all, or the named ones), check and build them, and merge them through a pull request
update *inputs:
    scripts/update-flake {{inputs}}

show:
    nix flake show

build:
    nixos-rebuild build --flake .

trace:
    nixos-rebuild build --flake . --show-trace

# A refactor that leaves the system unchanged keeps the same path
# Print the system derivation path with the git revision neutralised (working tree, or rev)
neutral host="wuwei" rev="":
    #!/usr/bin/env bash
    set -euo pipefail
    url="git+file://{{justfile_directory()}}"
    if [ -n "{{rev}}" ]; then url="$url?rev=$(git rev-parse "{{rev}}^{commit}")"; fi
    nix eval --raw --impure --expr "import {{justfile_directory()}}/scripts/neutral-toplevel.nix (builtins.getFlake \"$url\") \"{{host}}\""
    echo

# Check that the Darwin and WSL home bundles evaluate
platformcheck:
    nix build --no-link .#platformChecks.darwin .#platformChecks.wsl

# Run the VM integration tests (slow: builds and boots VMs)
vmtest:
    nix build --no-link -L .#vmTests.ssh

test:
    sudo nixos-rebuild test --flake .

boot:
    sudo nixos-rebuild boot --flake .

switch:
    sudo nixos-rebuild switch --flake .

garbage:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

optimise:
    sudo nix-store --optimise

sync:
    git town sync

vars:
    nix run .#flakeGitVars
