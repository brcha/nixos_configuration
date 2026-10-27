{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.cpp {
    home.packages = with pkgs; [
      # Build system
      cmake
      ninja

      # Clang toolchain
      ccls
      clang-analyzer
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
    # Memory profilers that work on Linux only
    ++ lib.optionals pkgs.stdenv.isLinux [
      pkgs.heaptrack
      pkgs.valgrind
    ];
  };
}
