{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.security {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
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
