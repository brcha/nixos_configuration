{ pkgs, lib, ... }:

{
  # `available [ ... ]` keeps the packages that build for this platform: listed for it in
  # meta.platforms and not marked broken there. A package that nixpkgs fixes later
  # (Scribus on Darwin, for example) comes back on its own
  _module.args.available = lib.filter (p:
    lib.meta.availableOn pkgs.stdenv.hostPlatform p && !(p.meta.broken or false));
}
