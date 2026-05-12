{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (steam.override {
      extraPkgs = pkgs: [
        vulkan-tools
        vulkan-loader
        mesa-demos
        gtk3
        gtk3-x11
        ocl-icd
        librsvg
      ];
    })
    (steam.override {
      extraPkgs = pkgs: [
        vulkan-tools
        vulkan-loader
        mesa-demos
        gtk3
        gtk3-x11
        ocl-icd
        librsvg
      ];
    }).run
    protontricks
  ];
}
