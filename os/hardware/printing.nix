{ pkgs, lib, config, flake, ... }:

{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      samsung-unified-linux-driver
    ];
  };
}
