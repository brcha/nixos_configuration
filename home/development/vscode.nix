{ pkgs, inputs, config, lib, ... }:

{
  config = lib.mkIf config.my.dev.vscode {
    programs.vscode = {
      enable = true;
    };
  };
}
