// The KDE platform theme would pick the Breeze controls style, which needs Kirigami
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
// Tray menus are platform (widget) menus, which need a QApplication
//@ pragma UseQApplication

import Quickshell

// The Hyprland shell: the bar with its cards, the dock, the window switcher and
// the overview. Only one card shows at a time: hovering does nothing while
// another card is held, a hover replaces another card's peek, and a click
// replaces either.
ShellRoot {
    id: root

    readonly property var cards: [calendar, weather, media]
    // Here, not inside Bar: there "weather" would name the bar's weather data
    readonly property var cardsByName: ({
            calendar: calendar,
            weather: weather,
            media: media
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

    Bar {
        id: bar

        popups: root.cards
        audioApps: media.apps

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
