import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// A card under the bar on the focused monitor. Hovering its bar module shows
// it (a peek); a click on the module holds it, and a held card closes on a
// click outside, on Esc, or on the next click on the module.
PanelWindow {
    id: root

    default property alias content: inner.data
    property bool open: false
    property bool held: false
    // Under the right end of the bar instead of centred
    property bool alignRight: false
    property double closedAt: 0
    property double leftAt: 0
    // The screen of the bar that asked for the card; the focused one if unset
    property var requestedScreen: null

    signal opened

    // A click on the bar to close a held card first ends the focus grab, which
    // closes it; the time check keeps the click from reopening it.
    function toggle(): void {
        if (held) {
            close();
        } else if (Date.now() - closedAt > 300) {
            show();
            held = true;
        }
    }

    // Waybar runs each enter and leave as its own process, so on a fast pass
    // the leave can arrive first; an enter right after it is ignored. So is one
    // right after closing, when the pointer is still on the module.
    function hoverEnter(): void {
        leaveTimer.stop();
        if (!open && Date.now() - leftAt > 100 && Date.now() - closedAt > 300)
            enterTimer.restart();
    }

    function hoverLeave(): void {
        leftAt = Date.now();
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

    // Passing over the module does not flash the card
    Timer {
        id: enterTimer

        interval: 150
        onTriggered: root.show()
    }

    // Time to cross the gap between the bar and the card
    Timer {
        id: leaveTimer

        interval: 250
        onTriggered: if (!cardHover.hovered && !root.held)
            root.hide()
    }

    visible: open
    color: "transparent"
    implicitWidth: card.width
    implicitHeight: card.height

    // Below the bar, centred unless alignRight, reserving no space. The bar reserves
    // none either, so the top margin counts from the screen edge: the Quickshell
    // bar's height + 6 (Waybar's 10 px margin + 30 px height comes to the same)
    anchors.top: true
    anchors.right: alignRight
    margins.top: Theme.barHeight + 6
    margins.right: alignRight ? 6 : 0
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    HyprlandFocusGrab {
        windows: [root]
        // Only a held card grabs. Not root.open: a grab started before the
        // window is mapped clears itself.
        active: root.held && root.visible
        onCleared: root.close()
    }

    onVisibleChanged: if (visible)
        openAnimation.restart()

    Rectangle {
        id: card

        width: inner.width + 2 * Theme.padding
        height: inner.height + 2 * Theme.padding
        radius: 12
        color: Theme.background
        border.color: Theme.raised
        border.width: 1

        HoverHandler {
            id: cardHover

            onHoveredChanged: {
                if (hovered)
                    leaveTimer.stop();
                else
                    root.hoverLeave();
            }
        }

        ParallelAnimation {
            id: openAnimation

            NumberAnimation {
                target: card
                property: "opacity"
                from: 0
                to: 1
                duration: 150
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: card
                property: "scale"
                from: 0.96
                to: 1
                duration: 150
                easing.type: Easing.OutCubic
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
}
