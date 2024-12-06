{ flake, pkgs, lib, config, ... }:

{
  # Default nix and nixpkgs configuration

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        # just a placeholder

        # Temporary addition for sonarr
        "aspnetcore-runtime-6.0.36"
        "aspnetcore-runtime-wrapped-6.0.36"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-wrapped-6.0.428"
      ];
    };
    overlays = [
      flake.inputs.self.overlays.unstable
    ];
  };

  nix = {
    nixPath = [
      "nixpkgs=${flake.inputs.nixpkgs}"
    ];

    package = pkgs.nixVersions.nix_2_18;

    registry.nixpkgs.flake = flake.inputs.nixpkgs;

    settings = {
      max-jobs = "auto";
      experimental-features = "nix-command flakes ca-derivations";
      auto-optimise-store = true;
      sandbox = true;

      # Trusted users (add support for mac, eventhough it's not used yet)
      trusted-users = [
        "root"
        (if pkgs.stdenv.isDarwin then flake.config.people.me else "@wheel")
      ];

      # workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;

      # This prevents outputs and dependencies of stuff in the store from being
      # garbage collected. Recommended for developing.

      # See https://github.com/nix-community/nix-direnv#via-home-manager
      keep-outputs = true;
      keep-derivations = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      dates = "weekly";
      persistent = true;
    };

    channel.enable = false; # no need for channels with flakes
  };
}
