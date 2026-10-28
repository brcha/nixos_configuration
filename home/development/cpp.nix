{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.cpp {
    home.packages = with pkgs; [
      # Build system
      cmake
      ninja

      # Clang toolchain
      ccls
      # On macOS both ship scan-view and set-xcode-analyzer; let clang-tools win
      (lib.lowPrio clang-analyzer)
      clang-tools
      clang_20

      # Debuggers
      gdb
      lldb

      # Misc
      pkg-config

      # Language servers (clangd comes with clang-tools)
      unstable.neocmakelsp
    ]
    # Memory profiler that works on Linux only (heaptrack, which needs KDE frameworks
    # for its GUI, is with the GUI dev tools)
    ++ lib.optional pkgs.stdenv.isLinux pkgs.valgrind;
  };
}
