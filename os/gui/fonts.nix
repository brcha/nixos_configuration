{ pkgs, lib, config, ... }:

{
  # Fonts
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "M+2 Nerd Font" "DejaVu Sans" ];
      };
    };
    fontDir.enable = true;
    packages = with pkgs; [
      fira
      fira-mono
      fira-code
      powerline-fonts
      source-code-pro
      source-sans-pro
      source-serif-pro
      terminus_font
      corefonts
      dejavu_fonts
      lato
      liberastika
      font-awesome
      material-icons
      roboto
      gentium
      gentium-book-basic
      raleway
      noto-fonts

      # Latin Modern
      lmodern
      lmmath

      # Family of fonts
      mplus-outline-fonts.githubRelease # Nice font with Japanese support
      iosevka
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };
}
