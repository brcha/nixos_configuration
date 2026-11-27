// The KDE platform theme would pick the Breeze controls style, which needs Kirigami
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
// Tray menus are platform (widget) menus, which need a QApplication
//@ pragma UseQApplication

import Quickshell
import Quickshell.Hyprland

// The Hyprland shell: the bar with its cards, the notifications, the dock, the
// window switcher and the overview. Only one card shows at a time: hovering does nothing while
// another card is held, a hover replaces another card's peek, and a click
// replaces either.
ShellRoot {
    id: root

    readonly property var cards: [calendar, weather, media, wifi, panel]
    // Here, not inside Bar: there "weather" would name the bar's weather data
    readonly property var cardsByName: ({
            calendar: calendar,
            weather: weather,
            media: media,
            wifi: wifi,
            notifications: panel
        })

    function enter(card): void {
        const others = cards.filter(c => c !== card);
        if (others.some(c => c.held))
            return;
        others.forEach(c => c.hide());
        card.hoverEnter();
    }

    function toggle(card): void {
        cards.filter(c => c !== card).forEach(c => c.hide());
        card.toggle();
    }

    CalendarCard {
        id: calendar
    }

    WeatherCard {
        id: weather
    }

    MediaCard {
        id: media
    }

    WifiCard {
        id: wifi
    }

    Notifications {
        id: notifications
    }

    NotificationPanel {
        id: panel

        bar: bar
        notifications: notifications
    }

    // Super+N and Super+Shift+N (binds in hyprland-shell.nix); the panel opens
    // under the bell of the focused screen
    GlobalShortcut {
        name: "notifications"
        onPressed: {
            const screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0];
            panel.requestedScreen = screen;
            panel.requestedModule = bar.bellFor(screen);
            root.toggle(panel);
        }
    }

    GlobalShortcut {
        name: "dnd"
        onPressed: notifications.dnd = !notifications.dnd
    }

    Bar {
        id: bar

        popups: root.cards
        notifications: notifications
        panel: panel

        onCardEnter: (name, screen, module) => {
            root.cardsByName[name].requestedScreen = screen;
            root.cardsByName[name].requestedModule = module;
            root.enter(root.cardsByName[name]);
        }
        onCardLeave: name => root.cardsByName[name].hoverLeave()
        onCardToggle: (name, screen, module) => {
            root.cardsByName[name].requestedScreen = screen;
            root.cardsByName[name].requestedModule = module;
            root.toggle(root.cardsByName[name]);
        }
    }

    Dock {}

    Switcher {}

    Overview {}
}
