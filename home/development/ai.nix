{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.ai {
    home.packages = with pkgs; [
      # AI coding assistants
      unstable.claude-code
      unstable.opencode
    ];
  };
}
