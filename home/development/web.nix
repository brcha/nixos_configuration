{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.web {
    home.packages = with pkgs; [
      # Node.js ecosystem
      nodejs
      prettier
      #nodePackages.vercel

      # Hosting CLIs
      heroku

      # Language servers
      unstable.graphql-language-service-cli
      unstable.svelte-language-server
      unstable.tailwindcss-language-server
      unstable.vscode-langservers-extracted
      unstable.vtsls
    ];
  };
}
