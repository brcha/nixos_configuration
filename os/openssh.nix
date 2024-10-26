{ lib, ... }:

{
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    allowSFTP = true;
    openFirewall = true;

    settings = {
      # algorithm choices mostly taken from:
      # https://blog.stribik.technology/2015/01/04/secure-secure-shell.html
      KexAlgorithms = [
        "sntrup761x25519-sha512@openssh.com" # new post-quantum kex
        "curve25519-sha256@libssh.org"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];

      # the -cert-v01 algos are *actually* CA-like certificate stuff:
      # https://superuser.com/questions/1225440/whats-the-purpose-of-ssh-ed25519-cert-v01
      #
      # the sk- algos correspond to -sk keys used with security keys with U2F/FIDO:
      # https://security.stackexchange.com/questions/240991/what-is-the-sk-ending-for-ssh-key-types
      HostKeyAlgorithms = "ssh-ed25519,ssh-ed25519-cert-v01@openssh.com";
      PubkeyAcceptedAlgorithms = "ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,ssh-rsa,ssh-rsa-cert-v01@openssh.com";

      # no root login and only pubkey auth
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false; # previously known as ChallengeResponseAuthentication
    };

    # By default this is merged with some undocumented default options, see:
    # https://github.com/NixOS/nixpkgs/pull/10155
    # https://github.com/NixOS/nixpkgs/pull/41745
    #
    # however I want to specify all authorized keys declaratively from this config
    # so: force overwrite the default with only the generated key files
    # the normal ~/.ssh/authorized_keys is ignored
    authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];

  };
}
