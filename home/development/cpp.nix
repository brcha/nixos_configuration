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
      unstable.neocmakelsp
    ]
    # Memory checker that works on Linux only
    ++ lib.optional pkgs.stdenv.isLinux pkgs.valgrind;
  };
}
