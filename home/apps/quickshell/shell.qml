// The KDE platform theme would pick the Breeze controls style, which needs Kirigami
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import Quickshell.Io

// Popups for the bar modules. Waybar calls them with
// qs ipc -c shell call <target> enter|leave|toggle; the Quickshell bar directly.
// Only one card shows at a time: hovering does nothing while another card is
// held, a hover replaces another card's peek, and a click replaces either.
ShellRoot {
    id: root

    readonly property var cards: [calendar, weather, media]

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

    // The Quickshell bar replaces Waybar while my.hyprland.quickshellBar is on
    LazyLoader {
        active: Quickshell.env("SHELL_BAR") === "1"

        Bar {
            readonly property var cards: ({
                    calendar: calendar,
                    weather: weather,
                    media: media
                })

            onCardEnter: (name, screen) => {
                cards[name].requestedScreen = screen;
                root.enter(cards[name]);
            }
            onCardLeave: name => cards[name].hoverLeave()
            onCardToggle: (name, screen) => {
                cards[name].requestedScreen = screen;
                root.toggle(cards[name]);
            }
        }
    }

    Switcher {}

    Overview {}

    IpcHandler {
        target: "calendar"

        function enter(): void {
            root.enter(calendar);
        }
        function leave(): void {
            calendar.hoverLeave();
        }
        function toggle(): void {
            root.toggle(calendar);
        }
    }

    IpcHandler {
        target: "weather"

        function enter(): void {
            root.enter(weather);
        }
        function leave(): void {
            weather.hoverLeave();
        }
        function toggle(): void {
            root.toggle(weather);
        }
    }

    IpcHandler {
        target: "media"

        function enter(): void {
            root.enter(media);
        }
        function leave(): void {
            media.hoverLeave();
        }
        function toggle(): void {
            root.toggle(media);
        }
    }
}
