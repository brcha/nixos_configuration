{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  me = flake.config.people.users.${flake.config.people.me};
in
{
  services.ollama = {
    enable = true;
    user = "ollama";
    group = "ollama";
    home = "/persist/ollama";
    acceleration = "cuda";
    loadModels = [
      "deepseek-r1"
      "deepseek-coder-v2"
    ];
  };

  services.nextjs-ollama-llm-ui = {
    enable = true;
    ollamaUrl = "http://ollama.home";
  };

  # Make a virtual host
  services.nginx = {
    enable = true;
    virtualHosts = {
      "ollama.home" = {
        locations."/" = { proxyPass = "http://localhost:3000"; };
      };
    };
  };

  networking.hosts = {
    "127.0.0.1" = [ "ollama.home" ];
  };
}
