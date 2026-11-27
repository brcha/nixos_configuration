{ flake, pkgs, lib, config, ... }:

let
  inherit (flake.config.people.users.${config.home.username}) location dockApps;

  # Plasma stays the default session, so nothing here may leak into it.
  enabled = pkgs.stdenv.isLinux && config.my.hyprland.enable;

  target = "wayland-session@hyprland.desktop.target";

  # Colour temperatures of the night light (K), also read for the notification panel
  dayTemp = 6500;
  nightTemp = 5000;

  # Weather for the bar and its card: wttr.in needs no key. The weather unit
  # writes the model to a cache file that both read; after a failed fetch they
  # keep showing the last one. A failed fetch still exits 0, so a network
  # hiccup does not show up as a failed unit in the bar.
  weatherCache = "${config.xdg.cacheHome}/weather.json";
  weather-fetch = pkgs.writeShellScript "weather-fetch" ''
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.curl pkgs.jq ]}:$PATH
    cache="${weatherCache}"
    json=$(curl -sf -m 10 'https://wttr.in/${location.city}?format=j1') || exit 0
    model=$(jq -c --arg now "$(date +%H:%M)" --arg city '${location.city}' -f ${./weather.jq} <<<"$json") || exit 0
    [ -n "$model" ] || exit 0
    mkdir -p "''${cache%/*}"
    printf '%s\n' "$model" > "$cache.tmp" && mv "$cache.tmp" "$cache"
  '';

  # Opened in a terminal from the bar's failed-units indicator
  failed-units = pkgs.writeShellScript "failed-units" ''
    systemctl --failed --no-pager
    systemctl --user --failed --no-pager
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

  # Night light state: wlsunset logs "setting temperature to N K" to the
  # journal while it changes the colour (every 20 s during a transition), so the
  # last such line of the running service is the current temperature. It logs
  # nothing when it starts in daylight, which means the daytime temperature.
  nightlight-status = pkgs.writeShellScript "nightlight-status" ''
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

  # Starts or stops the user unit named in $1 (from the bar or the notification
  # panel's quick settings)
  unit-toggle = pkgs.writeShellScript "unit-toggle" ''
    if systemctl --user is-active --quiet "$1"; then
      systemctl --user stop "$1"
    else
      systemctl --user start "$1"
    fi
  '';
in
{
  config = lib.mkIf enabled {
    # Units of the Hyprland session hang off the UWSM session target, not
    # graphical-session.target, which Plasma reaches as well.
    wayland.systemd.target = target;

    # Started and stopped from the bar and the notification panel; ends with the session
    systemd.user.services.stay-awake = {
      Unit = {
        Description = "Keep the Hyprland session awake (no lock, no screen-off)";
        PartOf = [ target ];
      };
      Service.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=idle --who='Hyprland bar' --why='Stay awake' ${pkgs.coreutils}/bin/sleep infinity";
    };

    # The bar, the dock, their cards, the notification server with its popups
    # and panel, the switcher and the overview; the unit already starts with the
    # session target
    programs.quickshell = {
      enable = true;
      configs.shell = ./quickshell;
      activeConfig = "shell";
      systemd.enable = true;
    };
    systemd.user.services.quickshell = {
      Unit = {
        PartOf = [ target ];
        # The unit names the config, not its store path; restart it when the QML changes
        X-Restart-Triggers = [ "${config.xdg.configFile."quickshell/shell".source}" ];
      };
      # kded6 must own the StatusNotifierWatcher before the bar's tray starts:
      # Quickshell would otherwise take the name, and the tray registrations
      # would go with every Quickshell restart, and with the bar when the
      # monitor output disappears (Qt apps then drop their tray icon for good).
      # Starts even if it fails.
      Service.ExecStartPre = "-${kded-watcher}";
      # The scripts the bar runs are not on PATH
      Service.Environment = [
        "UNIT_TOGGLE=${unit-toggle}"
        "NIGHTLIGHT_STATUS=${nightlight-status}"
        "FAILED_UNITS=${failed-units}"
        "DOCK_APPS=${lib.concatStringsSep "," dockApps}"
      ];
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

    # Fetched at login and every 30 minutes, outside the bar, so restarting the
    # bar neither refetches nor loses the weather
    systemd.user.services.weather = {
      Unit = {
        Description = "Weather for the Hyprland bar";
        PartOf = [ target ];
        After = [ target ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${weather-fetch}";
      };
      Install.WantedBy = [ target ];
    };

    systemd.user.timers.weather = {
      Unit.PartOf = [ target ];
      Timer.OnCalendar = "*:0/30";
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


          -- Screenshots
          hl.bind("Print", hl.dsp.exec_cmd("flameshot-hyprland gui"))

          -- Window switcher (Quickshell global shortcuts): releasing Alt switches,
          -- Alt+Escape cancels. The release bind is transparent, or the Alt+Tab bind
          -- shadows it while Alt is held; non_consuming lets applications see the
          -- release. Right Alt is AltGr in this keymap, so only Alt_L.
          local qs = function(name) return hl.dsp.global("quickshell:" .. name) end
          hl.bind("ALT + Tab",         qs("switcher-next"))
          hl.bind("ALT + SHIFT + Tab", qs("switcher-prev"))
          hl.bind("ALT + grave",       qs("switcher-prev"))
          hl.bind("ALT + Escape",      qs("switcher-cancel"))
          hl.bind("ALT + Alt_L",       qs("switcher-end"), { release = true, non_consuming = true, transparent = true })

          -- Workspace overview (Quickshell); it takes the keyboard while shown
          hl.bind(mainMod .. " + Tab", qs("overview"))

          -- Notification panel and do-not-disturb (Quickshell)
          hl.bind(mainMod .. " + N", qs("notifications"))
          hl.bind(mainMod .. " + SHIFT + N", qs("dnd"))
      end
    '';
  };
}
