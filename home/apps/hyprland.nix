{ pkgs, lib, osConfig ? { }, ... }:

let
  # Plasma stays the default session, so nothing here may leak into it.
  enabled = pkgs.stdenv.isLinux && (osConfig.programs.hyprland.enable or false);

  # Plasma autostart apps that should not start in Hyprland; UWSM runs XDG autostart
  plasmaOnly = [
    "app-org.kde.yakuake@autostart.service"
    "app-Flameshot@autostart.service"
    "app-syncthingtray@autostart.service"
    "app-clockify@autostart.service"
  ];

  # Flameshot has to use grim outside Plasma, but the setting lives in the
  # flameshot.ini that Plasma shares. A system-scope file found through
  # XDG_CONFIG_DIRS supplies it for Hyprland only.
  flameshot-hyprland = pkgs.writeShellScriptBin "flameshot-hyprland" ''
    export XDG_CONFIG_DIRS=${pkgs.writeTextDir "flameshot/flameshot.ini" ''
      [General]
      useGrimAdapter=true
    ''}:''${XDG_CONFIG_DIRS:-/etc/xdg}
    exec flameshot "$@"
  '';

  # Tray apps started before Waybar owns the StatusNotifierWatcher get no icon
  wait-for-tray = pkgs.writeShellScript "wait-for-tray" ''
    for _ in $(seq 50); do
      busctl --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1 && break
      sleep 0.2
    done
    exec "$@"
  '';

  # Clockify always shows its window at start and has no start-hidden option, but
  # closing the window only hides it to the tray; do that once the window appears
  clockify-hidden = pkgs.writeShellScript "clockify-hidden" ''
    PATH=${lib.makeBinPath [ pkgs.jq ]}:$PATH
    clockify --no-sandbox &
    for _ in $(seq 150); do
      addr=$(hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase == "clockify") | .address' | head -n 1)
      if [ -n "$addr" ]; then
        hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })"
        break
      fi
      sleep 0.2
    done
    wait
  '';

  # Power menu on Super+M: nothing happens on a stray key press, Cancel is the
  # first (default) entry, and Escape closes the menu too
  power-menu = pkgs.writeShellScript "power-menu" ''
    choice=$(printf '%s\n' "Cancel" "Log out" "Reboot" "Shut down" \
      | ${lib.getExe pkgs.fuzzel} --dmenu --prompt "Power: " --lines 4 --width 20)
    case "$choice" in
      "Log out") uwsm stop ;;
      "Reboot") systemctl reboot ;;
      "Shut down") systemctl poweroff ;;
    esac
  '';

  # The portal can start before the compositor's environment is imported and
  # then launches apps without WAYLAND_DISPLAY; restart it with that environment
  restartPortal = "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY"
    + " && systemctl --user restart xdg-desktop-portal.service";
in
{
  config = lib.mkIf enabled {
    wayland.windowManager.hyprland = {
      enable = true;

      # Hyprland itself and its portal come from the NixOS module (UWSM session)
      package = null;
      portalPackage = null;
      systemd.enable = false;

      # hyprlang is deprecated since Hyprland 0.55
      configType = "lua";

      extraConfig = ''
        -- Any monitor: highest refresh rate it offers, placed automatically
        hl.monitor({
            output   = "",
            mode     = "highrr",
            position = "auto",
            scale    = 1,
        })

        -- Run apps as UWSM-managed scopes
        local function run(cmd)
            return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
        end

        local mainMod = "SUPER"

        hl.config({
            general = {
                gaps_in     = 5,
                gaps_out    = 10,
                border_size = 2,
                layout      = "dwindle",
            },

            decoration = {
                rounding = 8,
            },

            dwindle = {
                preserve_split = true,
            },

            misc = {
                disable_hyprland_logo   = true,
                force_default_wallpaper = 0,
                -- Apps started with the session open their windows where you are
                initial_workspace_tracking = 0,
            },

            -- Mirrors the Plasma keyboard setup (kxkbrc); Super+Space toggles the layout (bound below)
            input = {
                kb_layout     = "us,rs",
                kb_variant    = ",yz",
                kb_model      = "pc104",
                kb_options    = "eurosign:e,compose:caps,lv3:ralt_switch",
                follow_mouse  = 1,
                accel_profile = "flat",
                sensitivity   = 0,
                numlock_by_default = true,
            },
        })

        -- Programs
        hl.bind(mainMod .. " + Return", run("ghostty"))
        hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("fuzzel")) -- wraps what it launches itself
        hl.bind(mainMod .. " + E",      run("dolphin"))
        hl.bind(mainMod .. " + R",      run("rtmapp")) -- todo list (Rusty Todo.txt Manager)

        -- Keyboard layout (us / rs). A Hyprland bind swallows the key press; the
        -- xkb option grp:win_space_toggle let terminal apps see Super+Space as a space
        hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

        -- Windows
        hl.bind(mainMod .. " + Q", hl.dsp.window.close())
        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))
        hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("${power-menu}"))

        -- Focus with arrows (Super+L is the lock screen)
        for key, dir in pairs({ left = "left", right = "right", up = "up", down = "down" }) do
            hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
        end

        -- Workspaces: Super+[0-9] to switch, Super+Shift+[0-9] to move the window
        for i = 1, 10 do
            local key = i % 10
            hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
            hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end
        hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

        -- Move/resize with the mouse
        hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
        hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        -- Volume and media keys
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
        hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
        hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
        hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
        hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })
        hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
        hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })

        -- Ignore maximize requests from apps
        hl.window_rule({
            name  = "suppress-maximize-events",
            match = { class = ".*" },

            suppress_event = "maximize",
        })

        -- Electron menus carry a transparent margin that blur turns into a smear;
        -- add the class of any other app that shows it
        for _, class in ipairs({ "[Ss]implenote" }) do
            hl.window_rule({
                name  = "no-blur-" .. class,
                match = { class = class },

                no_blur = true,
            })
        end

        -- Zoom opens helper windows when sharing (share toolbar, video window,
        -- annotation layer, short-lived popups). Tiled, they steal the layout and
        -- the focus and leave the meeting unusable: float them, and keep the pure
        -- overlays from taking focus when they appear.
        hl.window_rule({
            name  = "zoom-helpers-float",
            match = {
                class = "zoom",
                title = "^(as_toolbar|as_preview|annotate_toolbar|zoom_linux_float_video_window|zoom|Leave meeting panel)$",
            },

            float = true,
        })

        hl.window_rule({
            name  = "zoom-overlays-no-focus",
            match = {
                class = "zoom",
                title = "^(annotate_toolbar|zoom_linux_float_video_window|zoom)$",
            },

            no_initial_focus = true,
        })

        -- Modal dialogs (print, ...) would otherwise open in the top-left corner;
        -- menus are floating windows too, so floating alone is too broad
        hl.window_rule({
            name  = "center-modal",
            match = { modal = true },

            center = true,
        })

        hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
        for key, dir in pairs({ left = "left", right = "right", up = "up", down = "down" }) do
            hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
        end

        hl.on("hyprland.start", function()
            hl.exec_cmd("${restartPortal}")
            -- Plasma opens the wallet at login; elsewhere nothing connects PAM to KWallet
            hl.exec_cmd("uwsm app -- ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init")
            -- Tray apps (Plasma starts them through autostart or has a plasmoid)
            hl.exec_cmd("uwsm app -- ${wait-for-tray} kdeconnect-indicator")
            hl.exec_cmd("uwsm app -- ${wait-for-tray} flameshot-hyprland")
            hl.exec_cmd("uwsm app -- ${wait-for-tray} syncthingtray")
            hl.exec_cmd("uwsm app -- ${wait-for-tray} ${clockify-hidden}")
            -- No autostart entry exists for these two (the XDG autostart does not cover them)
            hl.exec_cmd("uwsm app -- ${wait-for-tray} megasync")
            hl.exec_cmd("uwsm app -- ${wait-for-tray} onedrivegui")
        end)
      '';
    };

    xdg.configFile = {
      # Sourced by UWSM for Hyprland sessions only. KDE apps get the Plasma style and
      # the Plasma application menu (Dolphin's "Open with", default apps). QtKeychain
      # (KMail, Akonadi) picks KWallet over the secret service only in a KDE session.
      "uwsm/env-hyprland".text = ''
        export QT_QPA_PLATFORMTHEME=kde
        export XDG_MENU_PREFIX=plasma-
        export KDE_FULL_SESSION=true
        export KDE_SESSION_VERSION=6
      '';
    } // lib.listToAttrs (map
      (unit: {
        name = "systemd/user/${unit}.d/plasma-only.conf";
        value.text = ''
          [Unit]
          ConditionEnvironment=XDG_CURRENT_DESKTOP=KDE
        '';
      })
      plasmaOnly);

    programs.ghostty = {
      enable = true;
      settings.scrollbar = "never";
    };

    programs.fuzzel = {
      enable = true;
      settings.main.launch-prefix = "uwsm app --";
    };

    home.packages = with pkgs; [
      flameshot-hyprland
      grim
      playerctl
    ];
  };
}
