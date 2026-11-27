# AGENTS.md — home/apps/

- An app's user unit lives in the app's module, inside its switch. A hand-made unit or autostart file that a managed one replaces must be removed by hand first, or activation fails.
- Never manage `mimeapps.list` or the GTK `settings.ini`: KDE rewrites them at runtime, and activation then fails with "would be clobbered".
- Change font rendering in `fonts.nix`, not System Settings: KDE's Fonts page rewrites the first file in `~/.config/fontconfig/conf.d/`, which is why those entries have `force = true`.
- KDE theming and integration go in `kde.nix`.
- Never run `superdirt-install`: its `Quarks.install` shadows the pinned quarks.

## Hyprland

- Nothing Hyprland-only may reach Plasma: bind its user units to `wayland-session@hyprland.desktop.target` (`wayland.systemd.target`), never `graphical-session.target` or `tray.target`.
- Keep packages that ship a D-Bus service or an XDG autostart file (swaync, `networkmanagerapplet`) out of the profile; a Home Manager module that always installs its package (`services.swaync`) cannot be used, so write that unit by hand.
- Check such leaks in the Home Manager output (`home-manager-files`, `.config/systemd/user`), not in the NixOS `etc/systemd/user` tree.
- UWSM runs XDG autostart: keep a Plasma autostart app out of Hyprland by adding its unit to `plasmaOnly` in `hyprland.nix`.
- Start tray apps from the `hyprland.start` hook through `wait-for-tray`: an app started before the bar's tray exists gets no icon.
- kded6 owns the StatusNotifierWatcher (`quickshell.service` loads it first), so tray registrations outlive Quickshell restarts; do not let Quickshell take the name.
- Start applications with `uwsm app -- ...`, so each runs in its own scope and survives a Quickshell restart.
- Validate the Lua config with the store binary, `<programs.hyprland.package>/bin/Hyprland --verify-config --config <file>`, not the capability wrapper on `PATH`; prepend `hl.timer = function() end` to the copy, or verify mode crashes on exit. `hyprctl eval '<lua>'` queries the running compositor.
- Home Manager owns `~/.config/hypr/hyprland.lua`: if Hyprland wrote a default one there, remove it before activating, or Home Manager aborts with "would be clobbered".

## Quickshell (`quickshell/`)

- Test a change with a temporary instance, `qs -p home/apps/quickshell` (with the unit's `Environment` for the bar's scripts); it reloads on every save, so stop it before editing again.
- Create `ScreencopyView`s only while their view is shown: capture requests during an output removal crash Hyprland.
- Cards live in the bar's window, never in a window of their own: mapping one ends the bar's hover, and a hovered card then hides and shows in a loop.
- Never change a `PopupWindow`'s `anchor.item` at run time (it crashes Quickshell 0.3.0); anchor to the window with a rectangle.
- `DesktopEntries.byId` and `heuristicLookup` do not notify: a binding that uses them also reads `DesktopEntries.applications.values`.
- `QsMenuAnchor` (tray menus) needs `//@ pragma UseQApplication` in `shell.qml`.
- An MPRIS player's `position` updates only when `positionChanged()` is called.
- Qt reports wuwei's mouse wheel as a touchpad: use a `WheelHandler` with `acceptedDevices: PointerDevice.AllDevices`; a `Slider`'s `wheelEnabled` never sees it.
- A `global` sent with `hyprctl` never arrives as `released`: test release binds from the keyboard.
- Qt's JavaScript engine has no `Array.prototype.flatMap`.
- Never name a QML file after a Qt Quick Controls type (`Popup`, `Calendar`): it shadows the import.
