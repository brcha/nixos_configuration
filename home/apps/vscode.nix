{ pkgs, inputs, config, lib, ... }:

{
  config = lib.mkIf config.my.apps.vscode {
    programs.vscode = {
      enable = true;
    };
  };
}
