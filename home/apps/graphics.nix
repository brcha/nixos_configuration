{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.graphics {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # Raster editors
      gimp
      krita

      # Vector editor
      inkscape

      # 3D and rendering
      povray

      # Desktop publishing
      scribus

      # Animation
      synfigstudio

      # Interior design
      sweethome3d.application
      sweethome3d.furniture-editor
      sweethome3d.textures-editor

      # Image processing
      imagemagick
    ]);
  };
}
