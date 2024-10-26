default:
    @just --list

fmt:
    treefmt

check:
    nix flake check

update:
    nix flake update
    git commit -m "chore: update flake inputs" flake.lock

show:
    nix flake show

build:
    nixos-rebuild build --flake .

boot:
    sudo nixos-rebuild boot --flake .

switch:
    sudo nixos-rebuild switch --flake .

garbage:
    sudo nix-collect-garbage -d

sync:
    git town sync

vars:
    nix run .#flakeGitVars
