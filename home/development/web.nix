{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Static site
    hugo

    # Node.js ecosystem
    nodejs
    prettier
    #nodePackages.vercel
    yarn

    # Hosting CLIs
    heroku
  ];
}
