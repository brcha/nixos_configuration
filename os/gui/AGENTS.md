# AGENTS.md — os/gui/

- Keep the commented `./hyprland.nix` line in `nixosModules.gui` (`default.nix`).
- With `my.hyprland.enable`, Hyprland is the default SDDM session and `kde.nix` keeps `plasma` as a `lib.mkDefault`; the default matters because the root rollback forgets SDDM's last session.
- Lock screen: use `security.pam.services.hyprlock = { }`, never `programs.hyprlock.enable`, which also starts a system `hypridle` unit in Plasma.
- KWallet is the only Secret Service provider; gnome-keyring stays off.
