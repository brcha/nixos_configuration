{ ... }:

{
  # Services add their interfaces to these zones; the zones themselves are defined only here
  services.firewalld = {
    enable = true;
    zones = {
      home = {
        forward = true;
      };
      # Trusted networks: everything arriving on an interface in this zone is accepted
      internal = {
        target = "ACCEPT";
        forward = true;
      };
    };
  };
}
