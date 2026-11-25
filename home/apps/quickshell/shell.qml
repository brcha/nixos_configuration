// The KDE platform theme would pick the Breeze controls style, which needs Kirigami
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import Quickshell.Io

// Popups for Waybar modules: qs ipc -c shell call <target> enter|leave|toggle.
// The cards share one place: hovering does nothing while the other card is
// held, a hover replaces the other card's peek, and a click replaces either.
ShellRoot {
    CalendarCard {
        id: calendar
    }

    WeatherCard {
        id: weather
    }

    IpcHandler {
        target: "calendar"

        function enter(): void {
            if (weather.held)
                return;
            weather.hide();
            calendar.hoverEnter();
        }
        function leave(): void {
            calendar.hoverLeave();
        }
        function toggle(): void {
            weather.hide();
            calendar.toggle();
        }
    }

    IpcHandler {
        target: "weather"

        function enter(): void {
            if (calendar.held)
                return;
            calendar.hide();
            weather.hoverEnter();
        }
        function leave(): void {
            weather.hoverLeave();
        }
        function toggle(): void {
            calendar.hide();
            weather.toggle();
        }
    }
}
