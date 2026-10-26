{ pkgs, ... }:

{
  # Settings for servers that are installed here but switched off (my.servers.*);
  # they apply once a switch is turned on

  # PostgreSQL lives on the hard disk
  services.postgresql.dataDir = "/data/postgresql/15";

  services.ollama = {
    home = "/persist/ollama";
    # The Radeon RX 9060 XT; Vulkan rather than ROCm until benchmarked
    package = pkgs.ollama-vulkan;
  };
}
