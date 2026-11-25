// The KDE platform theme would pick the Breeze controls style, which needs Kirigami
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import Quickshell.Io

// Popups opened from Waybar: qs ipc -c shell call <target> toggle.
// Opening one closes the other.
ShellRoot {
    CalendarCard {
        id: calendar
    }

    WeatherCard {
        id: weather
    }

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            weather.open = false;
            calendar.toggle();
        }
    }

    IpcHandler {
        target: "weather"

        function toggle(): void {
            calendar.open = false;
            weather.toggle();
        }
    }
}
