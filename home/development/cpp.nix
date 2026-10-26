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

      # Debuggers and profilers
      gdb
      heaptrack
      kdePackages.kcachegrind
      lldb
      valgrind

      # Diff tools
      kdiff3
      meld

      # Misc
      pkg-config

      # Language servers (clangd comes with clang-tools)
      unstable.neocmakelsp
    ];
  };
}
