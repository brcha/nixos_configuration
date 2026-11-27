import QtQuick
import Quickshell
import Quickshell.Hyprland

// A card that grows out of the bar, under the module that opened it. Hovering
// the module shows it (a peek); a click on the module holds it, and a held card
// closes on a click outside, on Esc, or on the next click on the module. The bar
// of the card's screen takes the card in while it shows: it draws the outline
// joined to the section above and slides the card in and out with reveal.
Item {
    id: root

    default property alias content: inner.data
    property bool open: false
    property bool held: false
    property double closedAt: 0
    // The screen and bar module that asked for the card; the focused screen if unset
    property var requestedScreen: null
    property Item requestedModule: null
    // The screen the card shows on, and the module it hangs from
    property var screen: null
    property Item module: null
    // 0 shut, 1 open; animated, so the card stays in its bar until it is shut
    property real reveal: open ? 1 : 0
    readonly property bool hosted: open || reveal > 0
    readonly property real cardWidth: inner.width + 2 * Theme.padding
    readonly property real cardHeight: inner.height + 2 * Theme.padding

    signal opened

    // A click on another screen's bar to close a held card first ends the focus
    // grab, which closes it; the time check keeps the click from reopening it.
    function toggle(): void {
        if (held) {
            close();
        } else if (Date.now() - closedAt > 300) {
            show();
            held = true;
            inner.forceActiveFocus();
        }
    }

    // An enter right after closing, with the pointer still on the module, is ignored
    function hoverEnter(): void {
        leaveTimer.stop();
        if (!open && Date.now() - closedAt > 300)
            enterTimer.restart();
    }

    function hoverLeave(): void {
        enterTimer.stop();
        if (open && !held)
            leaveTimer.restart();
    }

    function show(): void {
        enterTimer.stop();
        leaveTimer.stop();
        if (open)
            return;
        screen = requestedScreen ?? Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0];
        module = requestedModule;
        open = true;
        opened();
    }

    function hide(): void {
        enterTimer.stop();
        leaveTimer.stop();
        open = false;
        held = false;
    }

    function close(): void {
        hide();
        closedAt = Date.now();
    }

    Behavior on reveal {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // Passing over the module does not flash the card
    Timer {
        id: enterTimer

        interval: 150
        onTriggered: root.show()
    }

    // Time to move from the module into the card
    Timer {
        id: leaveTimer

        interval: 250
        onTriggered: if (!cardHover.hovered && !root.held)
            root.hide()
    }

    visible: hosted
    width: cardWidth
    height: cardHeight

    HoverHandler {
        id: cardHover

        onHoveredChanged: {
            if (hovered)
                leaveTimer.stop();
            else
                root.hoverLeave();
        }
    }

    Item {
        id: inner

        x: Theme.padding
        y: Theme.padding
        width: childrenRect.width
        height: childrenRect.height
        focus: true
        Keys.onEscapePressed: root.close()
    }
}
