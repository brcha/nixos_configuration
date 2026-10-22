{ pkgs, lib, osConfig ? { }, ... }:

let
  # Plasma stays the default session, so nothing here may leak into it.
  enabled = pkgs.stdenv.isLinux && (osConfig.programs.hyprland.enable or false);

  target = "wayland-session@hyprland.desktop.target";
in
{
  config = lib.mkIf enabled {
    # Units of the Hyprland session hang off the UWSM session target, not
    # graphical-session.target, which Plasma reaches as well.
    wayland.systemd.target = target;

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "hyprland/language" "pulseaudio" "network" "cpu" "memory" "tray" ];

        "hyprland/window".max-length = 60;
        "hyprland/language".format = "{short}";

        clock.format = "{:%a %d %b %H:%M}";
        cpu.format = "cpu {usage}%";
        memory.format = "mem {percentage}%";
        tray = {
          spacing = 8;
          # KDE Connect marks its icon passive while no device is reachable
          show-passive-items = true;
        };

        pulseaudio = {
          format = "vol {volume}%";
          format-muted = "muted";
          on-click = "pavucontrol";
        };

        network = {
          format-ethernet = "{ipaddr}";
          format-wifi = "{essid} {signalStrength}%";
          format-disconnected = "offline";
          on-click = "kcmshell6 kcm_networkmanagement";
        };
      };
    };

    # Home Manager also wants Waybar from tray.target, which Plasma could start one day
    systemd.user.services.waybar = {
      Unit.PartOf = lib.mkForce [ target ];
      Install.WantedBy = lib.mkForce [ target ];
    };

    # mako is not installed as a package or via D-Bus activation on purpose: its
    # D-Bus service file would let it grab org.freedesktop.Notifications in Plasma.
    services.mako = {
      enable = true;
      package = null;
      settings.default-timeout = 8000;
    };

    systemd.user.services.mako = {
      Unit = {
        Description = "mako";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = lib.getExe pkgs.mako;
        ExecReload = "${pkgs.mako}/bin/makoctl reload";
      };
      Install.WantedBy = [ target ];
    };

    # Colours of the Plasma scheme in use (Sweet-Mars); fuzzel defaults to a light theme
    programs.fuzzel.settings.colors = {
      background = "1c2124f2";
      text = "d3dae3ff";
      match = "f67e7dff";
      selection = "353945ff";
      selection-text = "d3dae3ff";
      selection-match = "f67e7dff";
      border = "f67e7dff";
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general.hide_cursor = true;

        background = [{ color = "rgba(25, 20, 20, 1.0)"; }];

        label = [{
          text = "$TIME";
          font_size = 64;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }];

        input-field = [{
          size = "300, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        };

        listener = [
          {
            timeout = 600;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 900;
            on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
            on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
          }
        ];
      };
    };

    services.hyprpolkitagent.enable = true;
    services.cliphist.enable = true;

    home.packages = with pkgs; [
      libnotify
      pavucontrol
      wl-clipboard
    ];

    wayland.windowManager.hyprland.extraConfig = ''
      do
          -- Plain colour background: no wallpaper daemon until an image is picked
          hl.config({
              misc = {
                  background_color = 0xff191414,
                  -- Lets a restarted hyprlock retake the lock if it ever crashes
                  allow_session_lock_restore = true,
              },
          })

          local mainMod = "SUPER"

          hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

          -- Clipboard history
          hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

          -- Screenshots
          hl.bind("Print", hl.dsp.exec_cmd("flameshot-hyprland gui"))
      end
    '';
  };
}
