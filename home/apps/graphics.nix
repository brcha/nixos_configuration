{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
  ];
}
