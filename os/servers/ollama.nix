{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  me = flake.config.people.users.${flake.config.people.me};
in
{
  services.ollama = {
    enable = true;
    sandbox = false;
    writablePaths = [ "/persist/ollama" ];
    acceleration = "cuda";
  };

  # Make a virtual host
  services.nginx = {
    enable = true;
    virtualHosts = {
      "ollama.home" = {
        locations."/" = { proxyPass = "http://localhost:11434"; };
      };
    };
  };

  networking.hosts = {
    "127.0.0.1" = [ "ollama.home" ];
  };
}
