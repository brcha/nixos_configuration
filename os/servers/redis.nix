{ pkgs, config, lib, ... }:

{
  options.my.servers.redis.enable = lib.mkEnableOption "Redis";

  config = lib.mkIf config.my.servers.redis.enable {
    # Redis
    services.redis.servers."" = { enable = true; };
  };
}
