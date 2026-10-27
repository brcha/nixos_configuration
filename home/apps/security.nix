{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.security {
    home.packages = available (with pkgs; [
      # Privacy browser
      tor-browser

      # Password manager GUI, and the browser bridge that lets browsers use gopass
      qtpass
      gopass-jsonapi

      # Antivirus GUI
      clamtk
    ]);
  };
}
