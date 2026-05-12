{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Cloud CLIs
    doctl

    # Web server
    caddy

    # Development environments
    devbox
    devenv

    # Kubernetes and IaC
    k9s
    kubernetes-helm
    terraform
    unstable.pulumi
  ];
}
