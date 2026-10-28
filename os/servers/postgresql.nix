{ flake, pkgs, lib, config, ... }:

let
  me = flake.config.people.me;
in
{
  options.my.servers.postgresql.enable = lib.mkEnableOption "PostgreSQL";

  config = lib.mkIf config.my.servers.postgresql.enable {
    # Postgresql
    services.postgresql = {
      enable = true; # collides with Odoo, so keep the switch off where Odoo runs
      enableTCPIP = true;
      package = pkgs.postgresql_15;
      extensions = with pkgs.postgresql15Packages; [
        postgis
        pgrouting
        pg_partman
      ];

      identMap = ''
        ${me} ${me} ${me}
        postgres ${me} postgres
        finland ${me} finland
        salmonquail ${me} salmonquail
      '';
      ensureDatabases = [ me "finland" "salmonquail" ];
      ensureUsers = [
        {
          name = me;
          ensureDBOwnership = true;
        }
        {
          name = "finland";
          ensureDBOwnership = true;
        }
        {
          name = "salmonquail";
          ensureDBOwnership = true;
        }
      ];
      authentication = ''
        local all all trust
        host  all all 127.0.0.1/32 trust
      '';
    };
  };
}
