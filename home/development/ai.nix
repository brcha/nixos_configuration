{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.ai {
    home.packages = with pkgs; [
      # AI coding assistants
      unstable.claude-code
      unstable.opencode
      unstable.grok-build
      cursor-cli # unstable's release, built in the overlay
    ];

    # Nix manages the grok binary; otherwise Grok installs its own updates into ~/.grok/bin
    home.sessionVariables.GROK_DISABLE_AUTOUPDATER = "1";
  };
}
