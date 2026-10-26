{ flake, config, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  me = flake.config.people.users.${flake.config.people.me};
in
{
  options.my.servers.ollama.enable = lib.mkEnableOption "Ollama";

  config = lib.mkIf config.my.servers.ollama.enable {
    services.ollama = {
      enable = true;
      user = "ollama";
      group = "ollama";
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
  };
}
