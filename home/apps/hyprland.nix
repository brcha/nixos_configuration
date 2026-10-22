{ pkgs, lib, osConfig ? { }, ... }:

let
  # Plasma stays the default session, so nothing here may leak into it.
  enabled = pkgs.stdenv.isLinux && (osConfig.programs.hyprland.enable or false);
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
        -- Single monitor
        hl.monitor({
            output   = "",
            mode     = "2560x1440@60",
            position = "0x0",
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
            },

            -- Mirrors the Plasma keyboard setup (kxkbrc); Win+Space toggles the layout
            input = {
                kb_layout     = "us,rs",
                kb_variant    = ",yz",
                kb_model      = "pc104",
                kb_options    = "eurosign:e,compose:caps,lv3:ralt_switch,grp:win_space_toggle",
                follow_mouse  = 1,
                accel_profile = "flat",
                sensitivity   = 0,
            },
        })

        -- Programs
        hl.bind(mainMod .. " + Return", run("ghostty"))
        hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("fuzzel")) -- wraps what it launches itself
        hl.bind(mainMod .. " + E",      run("dolphin"))

        -- Windows
        hl.bind(mainMod .. " + Q", hl.dsp.window.close())
        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))
        hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("uwsm stop"))

        -- Focus with arrows or vim keys
        for key, dir in pairs({ left = "left", right = "right", up = "up", down = "down",
                                H = "left", L = "right", K = "up", J = "down" }) do
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

        hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
        for key, dir in pairs({ left = "left", right = "right", up = "up", down = "down" }) do
            hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
        end

        -- Ghostty daemon owning F12 as a global shortcut (portal). Passed on the
        -- command line so the shared config does not grab F12 in Plasma, where
        -- Yakuake uses it.
        hl.on("hyprland.start", function()
            hl.exec_cmd("uwsm app -- ghostty --gtk-single-instance=true --initial-window=false"
                .. " --quit-after-last-window-closed=false"
                .. " --keybind=global:f12=toggle_quick_terminal")
        end)
      '';
    };

    programs.ghostty.enable = true;

    programs.fuzzel = {
      enable = true;
      settings.main.launch-prefix = "uwsm app --";
    };

    home.packages = with pkgs; [
      playerctl
    ];
  };
}
