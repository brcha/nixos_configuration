{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.gui.sshAgent {
    # SSH agent for the desktop sessions; its default follows gnome-keyring
    services.gnome.gcr-ssh-agent.enable = true;

    # gcr 3 provides the prompter gcr-ssh-agent asks key passphrases with;
    # only the gnome-keyring module adds it otherwise
    services.dbus.packages = [ pkgs.gcr ];
  };
}
