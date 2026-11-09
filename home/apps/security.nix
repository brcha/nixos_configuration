{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.security {
    home.packages = available (with pkgs; [
      # Privacy browser
      tor-browser

      # Browser bridge that lets browsers use gopass
      gopass-jsonapi

      # Antivirus GUI
      clamtk
    ]);
  };
}
