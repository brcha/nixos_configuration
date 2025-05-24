{ pkgs, libs, flake, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  system = {
    # Let `nixos-version --json` know about config revision
    configurationRevision = self.rev or self.dirtyRev or "empty";
    # add config revision to the boot entry
    nixos.tags = [
      "brcha-${self.shortRev or self.dirtyShortRev or "empty"}"
    ];
    # check the values of above vars with `just vars`
  };

  # Localization
  time.timeZone = "Europe/Belgrade";
  i18n = {
    defaultLocale = "C"; # I want default locale for the system-wide console
    extraLocales = [
      "en_US.UTF-8/UTF-8"
      "sr_RS/UTF-8"
      "sr_RS@latin/UTF-8"
    ];
  };
  console = {
    font = "LatArCyrHeb-16";
    keyMap = "us";
  };

  # Enable Geolocation
  location.provider = "geoclue2";

  # Base packages
  programs = {
    # Nice traceroute (better to declare it on root, to set capabilities)
    mtr.enable = true;

    # Enable git
    git = {
      enable = true;
      lfs.enable = true;
    };

    # Allow running unpatched binaries
    nix-ld.enable = true;
  };

  # Enable out-of-memory killer
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
  };

  # Enable systemd on initrd (not just for wuwei)
  boot.initrd.systemd.enable = true;

  # Enable firware update
  services.fwupd.enable = true;

  programs.gnupg.agent = { enable = true; };
  programs.ssh.startAgent = true;

  security = {
    pam = {
      services.login = {
        gnupg = {
          enable = true;
          storeOnly = true;
        };
        enableGnomeKeyring = true;
      };
    };
  };
}
