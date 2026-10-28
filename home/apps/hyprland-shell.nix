{ flake, pkgs, lib, config, ... }:

let
  inherit (flake.config.people.users.${config.home.username}) location;

  # Plasma stays the default session, so nothing here may leak into it.
  enabled = pkgs.stdenv.isLinux && config.my.hyprland.enable;

  target = "wayland-session@hyprland.desktop.target";

  # Colour temperatures of the night light (K), also read by the bar indicator
  dayTemp = 6500;
  nightTemp = 5000;

  # Weather for the bar: wttr.in needs no key; empty output hides the module
  weather = pkgs.writeShellScript "waybar-weather" ''
    PATH=${lib.makeBinPath [ pkgs.curl pkgs.jq ]}:$PATH
    text=$(curl -sf -m 10 'https://wttr.in/${location.city}?format=%c+%t&m') || exit 0
    tooltip=$(curl -sf -m 10 'https://wttr.in/${location.city}?0QTm&lang=sr') || tooltip=""
    jq -nc --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: ("<tt>" + $tooltip + "</tt>")}'
  '';

  # Night light indicator: wlsunset logs "setting temperature to N K" to the
  # journal while it changes the colour (every 20 s during a transition), so the
  # last such line of the running service is the current temperature. It logs
  # nothing when it starts in daylight, which means the daytime temperature.
  # A click toggles the service; the signal makes Waybar refresh the module.
  nightlight-status = pkgs.writeShellScript "waybar-nightlight" ''
    if ! systemctl --user is-active --quiet wlsunset; then
      echo '{"text": "󰖙", "class": "off", "tooltip": "Night light off (click to turn on)"}'
      exit 0
    fi
    invocation=$(systemctl --user show --property=InvocationID --value wlsunset)
    temp=$(journalctl --user --output=cat --no-pager "_SYSTEMD_INVOCATION_ID=$invocation" \
      | sed -n 's/^setting temperature to \([0-9]*\) K$/\1/p' | tail -n 1)
    temp=''${temp:-${toString dayTemp}}
    if [ "$temp" -ge ${toString dayTemp} ]; then
      icon=󰖙; class=day; phase="daylight"
    elif [ "$temp" -le ${toString nightTemp} ]; then
      icon=󰖔; class=night; phase="night"
    else
      icon=󰔎; class=transition; phase="changing"
    fi
    echo "{\"text\": \"$icon\", \"class\": \"$class\", \"tooltip\": \"Night light: $temp K ($phase). Click to turn off\"}"
  '';

  nightlight-toggle = pkgs.writeShellScript "waybar-nightlight-toggle" ''
    if systemctl --user is-active --quiet wlsunset; then
      systemctl --user stop wlsunset
    else
      systemctl --user start wlsunset
    fi
    systemctl --user kill --signal=SIGRTMIN+8 --kill-whom=main waybar.service
  '';
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
        modules-center = [ "clock" "custom/weather" ];
        modules-right = [ "custom/nightlight" "idle_inhibitor" "hyprland/language" "bluetooth" "pulseaudio" "network" "cpu" "memory" "tray" ];

        "hyprland/window".max-length = 60;
        "hyprland/language" = {
          format = "󰌌 {short}";
          on-click = "hyprctl switchxkblayout all next";
        };

        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
        };
        "custom/nightlight" = {
          exec = "${nightlight-status}";
          return-type = "json";
          interval = 30;
          signal = 8;
          on-click = "${nightlight-toggle}";
        };

        # Click to keep the screen awake: no lock and no screen-off while it is on
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
          tooltip-format-activated = "Staying awake: no lock, no screen-off";
          tooltip-format-deactivated = "Idle timers active (lock after 10 min)";
        };

        "custom/weather" = {
          exec = "${weather}";
          return-type = "json";
          interval = 1800;
        };
        cpu.format = "󰘚 {usage}%";
        memory.format = "󰍛 {percentage}%";
        tray = {
          spacing = 8;
          # Show idle (passive) items too, for example KDE Connect while no device is reachable
          show-passive-items = true;
        };

        bluetooth = {
          format = "󰂯";
          format-off = "󰂲";
          format-connected = "󰂱 {num_connections}";
          tooltip-format = "{controller_alias}  {status}";
          tooltip-format-connected = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          on-click = "kcmshell6 kcm_bluetooth";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
          on-click = "pavucontrol";
        };

        network = {
          format-ethernet = "󰈀";
          format-wifi = "󰖩 {essid}";
          format-disconnected = "󰖪";
          tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)  {ipaddr}";
          tooltip-format-disconnected = "offline";
          on-click = "kcmshell6 kcm_networkmanagement";
        };
      };

      # Colours of the Plasma scheme in use (Sweet-Mars)
      style = ''
        * {
          font-family: "M+2 Nerd Font", "Symbols Nerd Font", sans-serif;
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background: #1c2124;
          color: #d3dae3;
        }

        #workspaces button {
          padding: 0 8px;
          background: transparent;
          color: #d3dae3;
        }

        #workspaces button.active {
          background: #353945;
          color: #f67e7d;
          border-bottom: 2px solid #f67e7d;
        }

        #workspaces button.urgent {
          background: #f67e7d;
          color: #1c2124;
        }

        #window,
        #clock,
        #custom-weather,
        #idle_inhibitor,
        #custom-nightlight,
        #language,
        #bluetooth,
        #pulseaudio,
        #network,
        #cpu,
        #memory,
        #tray {
          padding: 0 10px;
        }

        #custom-nightlight.off {
          color: #7c818c;
        }

        #custom-nightlight.night {
          color: #f67e7d;
        }

        #idle_inhibitor.activated {
          color: #f67e7d;
        }

        #pulseaudio.muted,
        #bluetooth.off,
        #network.disconnected {
          color: #7c818c;
        }

        tooltip {
          background: #1c2124;
          border: 1px solid #f67e7d;
        }

        tooltip label {
          color: #d3dae3;
        }
      '';
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

    # Night light, like Plasma's Night Color (5000 K at night); sunrise and sunset
    # come from the user's fixed coordinates, the machine never moves
    services.wlsunset = {
      enable = true;
      inherit (location) latitude longitude;
      temperature = {
        day = dayTemp;
        night = nightTemp;
      };
    };

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
