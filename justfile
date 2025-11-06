default:
    @just --list

fmt:
    treefmt

check:
    nix flake check

update:
    nix flake update
    git commit -m "build: update flake inputs" flake.lock

show:
    nix flake show

build:
    nixos-rebuild build --flake .

trace:
    nixos-rebuild build --flake . --show-trace

boot:
    sudo nixos-rebuild boot --flake .

switch:
    sudo nixos-rebuild switch --flake .

garbage:
    sudo nix-collect-garbage -d

optimise:
    sudo nix-store --optimise

sync:
    git town sync

vars:
    nix run .#flakeGitVars
