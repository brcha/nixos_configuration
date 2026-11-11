{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.cpp {
    home.packages = with pkgs; [
      # Build system
      cmake
      ninja

      # Clang toolchain
      clang-tools
      clang

      # Debuggers
      gdb

      # Language servers (clangd comes with clang-tools)
      # Stable, because the unstable build fails until NixOS/nixpkgs#584958 reaches nixos-unstable
      neocmakelsp
    ]
    # Memory checker that works on Linux only
    ++ lib.optional pkgs.stdenv.isLinux pkgs.valgrind;
  };
}
