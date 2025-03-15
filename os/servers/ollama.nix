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
      "llama3.3"
      "llama3.2"
      "gemma3"
      "deepseek-r1"
      "deepseek-coder-v2"
    ];
  };
}
