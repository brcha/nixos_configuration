{ pkgs, lib, config, flake, ... }:

{
  options.my.hardware.printing.enable = lib.mkEnableOption "CUPS printing";

  config = lib.mkIf config.my.hardware.printing.enable {
    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        samsung-unified-linux-driver
      ];
    };
  };
}
