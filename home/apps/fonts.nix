{ ... }:

{
  fonts.fontconfig = {
    # Transcribed from the settings KDE's Fonts KCM had written into
    # 10-hm-fonts.conf: rgba=vbgr, hinting + hintstyle=hintslight, antialias.
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "vertical-bgr";
  };

  # KDE's Fonts KCM (KXftConfig) owns no config file of its own: on Apply it
  # rewrites the first fontconfig config file it finds under $HOME, which is
  # one of these. Let activation overwrite the result instead of aborting.
  xdg.configFile = {
    "fontconfig/conf.d/10-hm-fonts.conf".force = true;
    "fontconfig/conf.d/10-hm-rendering.conf".force = true;
    "fontconfig/conf.d/52-hm-default-fonts.conf".force = true;
  };
}
