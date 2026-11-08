{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.devops {
    home.packages = with pkgs; [
      # Development environments
      devbox
      devenv

      # Kubernetes
      k9s
    ];
  };
}
