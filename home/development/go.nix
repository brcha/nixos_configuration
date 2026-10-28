{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.go {
    home.packages = with pkgs; [
      go
      gotools
    ];
  };
}
