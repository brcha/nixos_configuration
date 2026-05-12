{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Static site
    hugo

    # Node.js ecosystem
    nodejs
    nodePackages.prettier
    nodePackages.vercel
    nodePackages.yarn

    # Hosting CLIs
    heroku
  ];
}
