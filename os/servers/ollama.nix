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
      #"llama3.3" # requires too much memory
      "llama3.2"
      #      "gemma3"
      #      "phi4"
      #      "deepseek-r1"
      #      "deepseek-coder-v2"
      #      "qwen2.5-coder"
      #      "qwen2.5"
    ];
  };
}
