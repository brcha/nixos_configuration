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
    # Memory profiler that works on Linux only (heaptrack, which needs KDE frameworks
    # for its GUI, is with the GUI dev tools)
    ++ lib.optional pkgs.stdenv.isLinux pkgs.valgrind;
  };
}
