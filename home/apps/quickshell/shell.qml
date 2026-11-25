// The KDE platform theme would pick the Breeze controls style, which needs Kirigami
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import Quickshell.Io

// Popups opened from Waybar: qs ipc -c shell call <target> toggle
ShellRoot {
    CalendarCard {
        id: calendar
    }

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            calendar.toggle();
        }
    }
}
