# Two-node VM test: a bare server (the core and every switchable module, no
# home-manager) must boot cleanly, accept SSH and drop ports it does not open.
# Run with `just vmtest`.
{ self, pkgs, me }:

pkgs.testers.runNixOSTest {
  name = "ssh-firewall";

  # The modules take the `flake` argument, which only nixos-unified passes, and
  # the core sets nixpkgs.config and overlays
  node.specialArgs = self.nixos-unified.lib.specialArgsFor.nixos;
  node.pkgsReadOnly = false;

  nodes.server = { lib, pkgs, ... }: {
    imports = [ self.nixosModules.default self.nixosModules.linux ];

    # The VM cannot decrypt the sops password
    users.users.${me} = {
      hashedPasswordFile = lib.mkForce null;
      password = "test";
    };

    # Something listening on a port the firewall does not open
    systemd.services.listener = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.netcat}/bin/nc -lk 8000";
    };
  };

  nodes.client = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.netcat ];
  };

  testScript = ''
    start_all()

    server.wait_for_unit("multi-user.target")
    server.wait_for_unit("sshd.service")
    server.wait_for_open_port(8000)
    failed = server.succeed("systemctl --failed --no-legend")
    assert failed.strip() == "", f"failed units on the server:\n{failed}"

    client.wait_for_unit("multi-user.target")
    client.succeed("nc -z -w 5 server 22")
    # The default zone drops, so a blocked port times out
    client.fail("nc -z -w 5 server 8000")
    # Opening the port makes it reachable, so the firewall was what blocked it
    server.succeed("firewall-cmd --add-port=8000/tcp")
    client.succeed("nc -z -w 5 server 8000")
  '';
}
