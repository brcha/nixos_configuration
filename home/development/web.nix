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

    # Language servers
    unstable.graphql-language-service-cli
    unstable.svelte-language-server
    unstable.tailwindcss-language-server
    unstable.vscode-langservers-extracted
    unstable.vtsls
  ];
}
