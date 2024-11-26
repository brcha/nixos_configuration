{ pkgs, lib, config, ... }:

{
  # Postgresql
  services.postgresql = {
    #    enable = true; # Colides with Odoo at the moment, so disable now
    enableTCPIP = true;
    package = pkgs.postgresql_15;
    extensions = with pkgs.postgresql15Packages; [
      postgis
      pgrouting
      pg_partman
    ];

    dataDir = "/data/postgresql/15"; # have postgre on hdd
    identMap = ''
      brcha brcha brcha
      postgres brcha postgres
      finland brcha finland
      salmonquail brcha salmonquail
    '';
    ensureDatabases = [ "brcha" "finland" "salmonquail" ];
    ensureUsers = [
      {
        name = "brcha";
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
}
