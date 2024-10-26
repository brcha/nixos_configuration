{ pkgs, misc, lib, ... }:

{
  home.packages = with pkgs; [
    sccache
  ];
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';
}
