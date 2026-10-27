{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.graphics {
    home.packages = available
      (with pkgs; [
        # Raster editors
        gimp
        krita

        # Vector editor
        inkscape

        # Desktop publishing. nixpkgs marks Scribus broken on Darwin, so the Mac skips it
        # for now; it returns there once nixpkgs fixes it (check on the Mac when updating)
        scribus

        # Animation
        synfigstudio
      ])
    # Interior design; the nixpkgs build fails on macOS (it cannot find the bundled
    # JDK's libjli.dylib), so Linux only for now
    ++ lib.optionals pkgs.stdenv.isLinux (with pkgs.sweethome3d; [
      application
      furniture-editor
      textures-editor
    ]);
  };
}
