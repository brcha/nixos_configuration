{ flake, pkgs, lib, config, ... }:

let
  inherit (flake.config.people.users.${config.home.username}) location;

  # Plasma stays the default session, so nothing here may leak into it.
  enabled = pkgs.stdenv.isLinux && config.my.hyprland.enable;

  target = "wayland-session@hyprland.desktop.target";

  # Colour temperatures of the night light (K), also read by the bar indicator
  dayTemp = 6500;
  nightTemp = 5000;

  # Bar drawers open to the left, so the hovered leader stays under the pointer
  # in the right-aligned section
  drawer = {
    transition-duration = 300;
    reveal-delay = 200;
    transition-left-to-right = false;
    click-to-pin = true;
  };

  # Weather for the bar: wttr.in needs no key; empty output hides the module
  weather = pkgs.writeShellScript "waybar-weather" ''
    PATH=${lib.makeBinPath [ pkgs.curl pkgs.jq ]}:$PATH
    text=$(curl -sf -m 10 'https://wttr.in/${location.city}?format=%c+%t&m') || exit 0
    tooltip=$(curl -sf -m 10 'https://wttr.in/${location.city}?0QTm&lang=sr') || tooltip=""
    jq -nc --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: ("<tt>" + $tooltip + "</tt>")}'
  '';

  # Shown until the first Bing image has been downloaded
  fallbackWallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/ScarletTree/contents/images_dark/5120x2880.png";

  # Bing picture of the day, like Plasma's: the image is saved under its date, so
  # hyprpaper never sees new content behind a path it has already loaded. Without
  # a network the newest saved image is used. hyprpaper accepts an empty monitor
  # name but ignores it, and rejects "*", so every monitor is named.
  bing-wallpaper = pkgs.writeShellScript "bing-wallpaper" ''
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.curl pkgs.jq ]}:$PATH
    dir="${config.xdg.cacheHome}/bing-wallpaper"
    mkdir -p "$dir"
    if info=$(curl -sf -m 20 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1'); then
      date=$(jq -r '.images[0].startdate' <<<"$info")
      base=$(jq -r '.images[0].urlbase' <<<"$info")
      file="$dir/$date.jpg"
      if [ ! -s "$file" ] && curl -sf -m 60 -o "$file.part" "https://www.bing.com''${base}_UHD.jpg"; then
        mv "$file.part" "$file"
        find "$dir" -name '*.jpg' ! -name "$date.jpg" -delete
      fi
      rm -f "$file.part"
    fi
    file=$(ls -1 "$dir"/*.jpg 2>/dev/null | tail -n 1)
    [ -n "$file" ] || exit 0
    # hyprpaper may still be starting at login
    for _ in $(seq 10); do
      monitors=$(hyprctl monitors -j | jq -r '.[].name')
      ok=''${monitors:+1}
      for monitor in $monitors; do
        hyprctl hyprpaper wallpaper "$monitor,$file" || ok=
      done
      [ -n "$ok" ] && exit 0
      sleep 1
    done
    exit 1
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

  # Activates kded6 and asks for its StatusNotifierWatcher. The module is not
  # marked load-on-demand, so it may only arrive through kded6's autoload; wait
  # (at most 10 s) until the watcher name has an owner.
  kded-watcher = pkgs.writeShellScript "kded-watcher" ''
    PATH=${lib.makeBinPath [ pkgs.systemd pkgs.coreutils ]}:$PATH
    busctl --user call org.kde.kded6 /kded org.kde.kded6 loadModule s statusnotifierwatcher
    for _ in $(seq 50); do
      busctl --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0
      sleep 0.2
    done
    exit 1
  '';

  # Starts or stops the user unit named in $1, then has Waybar refresh the
  # modules on signal 8, which show the units' state
  unit-toggle = pkgs.writeShellScript "waybar-unit-toggle" ''
    if systemctl --user is-active --quiet "$1"; then
      systemctl --user stop "$1"
    else
      systemctl --user start "$1"
    fi
    systemctl --user kill --signal=SIGRTMIN+8 --kill-whom=main waybar.service
  '';

  # Stay awake is a systemd idle inhibitor (the stay-awake unit), which hypridle
  # obeys; unlike Waybar's own inhibitor, a script can read its state
  stay-awake-status = pkgs.writeShellScript "waybar-stay-awake" ''
    if systemctl --user is-active --quiet stay-awake; then
      echo '{"text": "󰅶", "class": "activated", "tooltip": "Staying awake: no lock, no screen-off"}'
    else
      echo '{"text": "󰾪", "class": "deactivated", "tooltip": "Idle timers active (lock after 10 min)"}'
    fi
  '';

  # Drawer leaders: a fixed icon per drawer, with the class "on" (accent) when
  # something inside is on, or "off" (dimmed) when the network is down
  toggles-leader = pkgs.writeShellScript "waybar-toggles" ''
    PATH=${lib.makeBinPath [ pkgs.jq ]}:$PATH
    class=""
    case $(${nightlight-status} | jq -r .class) in
      night) night="night"; class=on ;;
      transition) night="changing"; class=on ;;
      day) night="daylight" ;;
      *) night="off" ;;
    esac
    awake="off"
    if systemctl --user is-active --quiet stay-awake; then
      awake="on"; class=on
    fi
    jq -nc --arg class "$class" --arg night "$night" --arg awake "$awake" \
      '{text: "󰔡", class: ([$class] - [""]), tooltip: "Night light: \($night)\nStay awake: \($awake)"}'
  '';

  # bluetoothctl waits for bluetoothd forever when it is not running
  connectivity-leader = pkgs.writeShellScript "waybar-connectivity" ''
    PATH=${lib.makeBinPath [ pkgs.networkmanager pkgs.bluez pkgs.coreutils pkgs.jq ]}:$PATH
    state=$(nmcli -t -f STATE general 2>/dev/null)
    devices=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-)
    if [[ $state != connected* ]]; then
      class=off
    elif [ -n "$devices" ]; then
      class=on
    else
      class=""
    fi
    jq -nc --arg class "$class" --arg state "''${state:-unknown}" --arg devices "$devices" \
      '{text: "󰛳", class: ([$class] - [""]),
        tooltip: "Network: \($state)\nBluetooth: \(if $devices == "" then "nothing connected" else ($devices | split("\n") | join(", ")) end)"}'
  '';

  # Busy at 80 % load per CPU or memory in use
  system-leader = pkgs.writeShellScript "waybar-system" ''
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gawk pkgs.jq ]}:$PATH
    read -r load _ </proc/loadavg
    cpus=$(nproc)
    loadpct=$(awk -v l="$load" -v n="$cpus" 'BEGIN { printf "%d", l * 100 / n }')
    mem=$(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 } END { printf "%d", (t - a) * 100 / t }' /proc/meminfo)
    class=""
    if [ "$loadpct" -ge 80 ] || [ "$mem" -ge 80 ]; then
      class=on
    fi
    jq -nc --arg class "$class" --arg load "$load" --arg loadpct "$loadpct" --arg cpus "$cpus" --arg mem "$mem" \
      '{text: "󰊚", class: ([$class] - [""]), tooltip: "Load: \($load) (\($loadpct) % of \($cpus) CPUs)\nMemory: \($mem) % in use"}'
  '';

  # SwayNotificationCenter: popups plus a panel with past notifications
  swaync = pkgs.swaynotificationcenter;
  swaync-client = "${swaync}/bin/swaync-client";

  # Popups drawn by Quickshell (config in ./quickshell), opened from the bar
  quickshell-ipc = "${config.programs.quickshell.package}/bin/qs ipc -c shell call";

  # Only what differs from swaync's defaults
  swaync-config = pkgs.writeText "swaync-config.json" (builtins.toJSON {
    timeout = 8;
    widgets = [ "title" "dnd" "notifications" ];
  });

  # Sweet-Mars colours on top of the packaged style
  swaync-style = pkgs.writeText "swaync-style.css" ''
    :root {
      --cc-bg: rgba(28, 33, 36, 0.95);
      --noti-border-color: #f67e7d;
      --noti-bg: 28, 33, 36;
      --noti-bg-alpha: 0.95;
      --noti-bg-darker: #161a1c;
      --noti-bg-hover: #353945;
      --noti-bg-focus: rgba(53, 57, 69, 0.6);
      --noti-close-bg: #353945;
      --noti-close-bg-hover: #f67e7d;
      --text-color: #d3dae3;
      --text-color-disabled: #7c818c;
      --bg-selected: #f67e7d;
    }

    * {
      font-family: "M+2 Nerd Font", "Symbols Nerd Font", sans-serif;
    }
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
      # 0.16 for the drawers' reveal delay and expanded class; the local patch adds
      # click-to-pin, which upstream Waybar does not have
      package = pkgs.unstable.waybar.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./waybar-drawer-pin.patch ];
      });

      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "custom/launcher" "hyprland/workspaces" "wlr/taskbar" "hyprland/window" ];
        modules-center = [ "clock" "custom/weather" ];
        modules-right = [ "privacy" "group/toggles" "pulseaudio" "group/connectivity" "group/system" "custom/notifications" "group/tray-drawer" ];

        # Hover drawers: the first module (the leader) stays visible, the others
        # slide out. Not "group/tray": the group box would share the tray's CSS name.
        "group/toggles" = {
          orientation = "inherit";
          inherit drawer;
          modules = [ "custom/toggles" "custom/nightlight" "custom/idle" "hyprland/language" ];
        };
        "group/connectivity" = {
          orientation = "inherit";
          inherit drawer;
          modules = [ "custom/connectivity" "network" "bluetooth" ];
        };
        "group/system" = {
          orientation = "inherit";
          inherit drawer;
          modules = [ "custom/system" "cpu" "memory" ];
        };
        "group/tray-drawer" = {
          orientation = "inherit";
          inherit drawer;
          modules = [ "custom/tray" "tray" ];
        };
        "custom/toggles" = {
          exec = "${toggles-leader}";
          return-type = "json";
          interval = 30;
          signal = 8;
        };
        "custom/connectivity" = {
          exec = "${connectivity-leader}";
          return-type = "json";
          # Bluetooth device names are not markup
          escape = true;
          interval = 10;
        };
        "custom/system" = {
          exec = "${system-leader}";
          return-type = "json";
          interval = 10;
        };
        "custom/tray" = {
          format = "󱊔";
          tooltip-format = "Tray";
        };
        # Same command as the Super+D bind
        "custom/launcher" = {
          format = "";
          tooltip-format = "Launcher (Super+D)";
          on-click = "${lib.getExe config.programs.vicinae.package} toggle";
        };

        # The defaults watch screen sharing, the microphone and location
        privacy.icon-size = 16;

        "hyprland/window" = {
          max-length = 60;
          icon = true;
          icon-size = 18;
        };
        # Lists the windows of all workspaces: the module has no per-workspace filter
        "wlr/taskbar" = {
          icon-size = 18;
          on-click = "activate";
          on-click-middle = "close";
        };
        "hyprland/language" = {
          format = "󰌌 {short}";
          on-click = "hyprctl switchxkblayout all next";
        };

        # Click for the calendar popup (Quickshell)
        clock = {
          format = "󰃭 {:%a %d %b  %H:%M}";
          tooltip = false;
          on-click = "${quickshell-ipc} calendar toggle";
        };
        "custom/nightlight" = {
          exec = "${nightlight-status}";
          return-type = "json";
          interval = 30;
          signal = 8;
          on-click = "${unit-toggle} wlsunset";
        };

        # Click for the notification panel, right-click for do-not-disturb
        "custom/notifications" = {
          exec = "${swaync-client} -swb";
          return-type = "json";
          escape = true;
          format = "{icon}";
          format-icons = {
            notification = "󱅫";
            none = "󰂚";
            dnd-notification = "󰂛";
            dnd-none = "󰂛";
            inhibited-notification = "󰂛";
            inhibited-none = "󰂛";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰂛";
          };
          on-click = "${swaync-client} -t -sw";
          on-click-right = "${swaync-client} -d -sw";
        };

        # Click to keep the screen awake: no lock and no screen-off while it is on
        "custom/idle" = {
          exec = "${stay-awake-status}";
          return-type = "json";
          interval = 30;
          signal = 8;
          on-click = "${unit-toggle} stay-awake";
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

        #taskbar button {
          padding: 0 4px;
          background: transparent;
        }

        #taskbar button.active {
          background: #353945;
          border-bottom: 2px solid #f67e7d;
        }

        #custom-launcher,
        #window,
        #clock,
        #custom-weather,
        #custom-idle,
        #custom-nightlight,
        #custom-toggles,
        #custom-connectivity,
        #custom-system,
        #language,
        #bluetooth,
        #pulseaudio,
        #network,
        #cpu,
        #memory,
        #tray,
        #custom-tray,
        #custom-notifications {
          padding: 0 10px;
        }

        #privacy {
          padding: 0 10px;
        }

        #privacy-item {
          color: #f67e7d;
        }

        .drawer-child {
          background: #353945;
        }

        #toggles.expanded,
        #connectivity.expanded,
        #system.expanded,
        #tray-drawer.expanded {
          border-bottom: 2px solid #7c818c;
        }

        /* After .expanded: a pinned group carries both classes */
        #toggles.pinned,
        #connectivity.pinned,
        #system.pinned,
        #tray-drawer.pinned {
          border-bottom: 2px solid #f67e7d;
        }

        #custom-notifications.notification {
          color: #f67e7d;
        }

        #custom-notifications.dnd-none,
        #custom-notifications.dnd-notification,
        #custom-notifications.inhibited-none,
        #custom-notifications.inhibited-notification,
        #custom-notifications.dnd-inhibited-none,
        #custom-notifications.dnd-inhibited-notification {
          color: #7c818c;
        }

        #custom-notifications.cc-open {
          border-bottom: 2px solid #f67e7d;
        }

        #custom-nightlight.off {
          color: #7c818c;
        }

        #custom-nightlight.night {
          color: #f67e7d;
        }

        #custom-idle.activated,
        #custom-toggles.on,
        #custom-connectivity.on,
        #custom-system.on {
          color: #f67e7d;
        }

        #custom-connectivity.off,
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
      # Waybar's built-in StatusNotifierWatcher goes away on every restart and with
      # the bar when the monitor output disappears; Qt apps then drop their tray
      # icon for good. kded6's watcher (D-Bus activated) outlives both, so it has to
      # own the name before Waybar starts. Waybar starts even if this fails.
      Service.ExecStartPre = "-${kded-watcher}";
    };

    # Started and stopped from the bar only; ends with the session
    systemd.user.services.stay-awake = {
      Unit = {
        Description = "Keep the Hyprland session awake (no lock, no screen-off)";
        PartOf = [ target ];
      };
      Service.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=idle --who=Waybar --why='Stay awake' ${pkgs.coreutils}/bin/sleep infinity";
    };

    # swaync is not installed as a package or via D-Bus activation on purpose: its
    # D-Bus service file would let it grab org.freedesktop.Notifications in Plasma.
    # The Home Manager module always installs it, so the unit is written here.
    # Not installed, swaync cannot find its packaged base style; pass it explicitly.
    systemd.user.services.swaync = {
      Unit = {
        Description = "SwayNotificationCenter";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${lib.getExe swaync} --config ${swaync-config} --style ${swaync-style} --custom-system-css ${swaync}/etc/xdg/swaync/style.css";
        Restart = "on-failure";
      };
      Install.WantedBy = [ target ];
    };

    # Popup widgets under the bar; the unit already starts with the session target
    programs.quickshell = {
      enable = true;
      configs.shell = ./quickshell;
      activeConfig = "shell";
      systemd.enable = true;
    };
    systemd.user.services.quickshell.Unit = {
      PartOf = [ target ];
      # The unit names the config, not its store path; restart it when the QML changes
      X-Restart-Triggers = [ "${config.xdg.configFile."quickshell/shell".source}" ];
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

    # On-screen indicator for the media key and Num Lock binds. The Home
    # Manager unit already hangs off wayland.systemd.target. The style replaces
    # the packaged one: Sweet-Mars colours on its layout.
    services.swayosd = {
      enable = true;
      stylePath = pkgs.writeText "swayosd.css" ''
        window#osd {
          border-radius: 999px;
          border: 1px solid #353945;
          background: alpha(#161a1c, 0.9);
        }
        window#osd #container {
          margin: 16px;
        }
        window#osd image,
        window#osd label {
          color: #d3dae3;
        }
        window#osd image:disabled,
        window#osd label:disabled {
          color: #7c818c;
        }
        window#osd progressbar,
        window#osd segmentedprogress {
          min-height: 6px;
          border-radius: 999px;
          background: transparent;
          border: none;
        }
        window#osd trough,
        window#osd segment {
          min-height: inherit;
          border-radius: inherit;
          border: none;
          background: #353945;
        }
        window#osd progress,
        window#osd segment.active {
          min-height: inherit;
          border-radius: inherit;
          border: none;
          background: #f67e7d;
        }
        window#osd progressbar:disabled progress {
          background: #7c818c;
        }
        window#osd segment {
          margin-left: 8px;
        }
        window#osd segment:first-child {
          margin-left: 0;
        }
      '';
    };

    # The Home Manager unit already hangs off wayland.systemd.target
    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        wallpaper = [{ monitor = "*"; path = fallbackWallpaper; }];
      };
    };

    # A restarted hyprpaper starts with the fallback; hand it the Bing image again
    systemd.user.services.hyprpaper.Service.ExecStartPost = "${pkgs.systemd}/bin/systemctl --user start --no-block bing-wallpaper.service";

    # Checked hourly: Bing changes the image once a day, at a time that depends
    # on the market
    systemd.user.services.bing-wallpaper = {
      Unit = {
        Description = "Bing picture of the day as the Hyprland wallpaper";
        PartOf = [ target ];
        After = [ target "hyprpaper.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${bing-wallpaper}";
      };
      Install.WantedBy = [ target ];
    };

    systemd.user.timers.bing-wallpaper = {
      Unit.PartOf = [ target ];
      Timer.OnCalendar = "hourly";
      Install.WantedBy = [ target ];
    };

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
          -- Shown while hyprpaper loads the wallpaper
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

          -- Notification panel and do-not-disturb
          hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("${swaync-client} -t -sw"))
          hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("${swaync-client} -d -sw"))

          -- Screenshots
          hl.bind("Print", hl.dsp.exec_cmd("flameshot-hyprland gui"))
      end
    '';
  };
}
