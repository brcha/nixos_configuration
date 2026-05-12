{ pkgs, ... }:

{
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
    massif-visualizer
    valgrind

    # Diff tools
    kdiff3
    meld

    # Misc
    pkg-config
  ];
}
