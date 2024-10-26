{ pkgs, config, lib, ... }:

{
  # Redis
  services.redis.servers."" = { enable = true; };
}
