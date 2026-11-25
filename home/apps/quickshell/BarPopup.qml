import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// A card under the bar on the focused monitor. It closes on a click outside,
// on Esc, or on the next toggle().
PanelWindow {
    id: root

    default property alias content: inner.data
    property bool open: false
    property double closedAt: 0

    signal opened

    // A click on the bar to close an open popup first ends the focus grab,
    // which closes it; the time check keeps the toggle from reopening it.
    function toggle(): void {
        if (open) {
            open = false;
        } else if (Date.now() - closedAt > 300) {
            screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0];
            open = true;
            opened();
        }
    }

    function close(): void {
        open = false;
        closedAt = Date.now();
    }

    visible: open
    color: "transparent"
    implicitWidth: card.width
    implicitHeight: card.height

    // Below the bar, centred, reserving no space
    anchors.top: true
    margins.top: 6
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    HyprlandFocusGrab {
        windows: [root]
        // Not root.open: a grab started before the window is mapped clears itself
        active: root.visible
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
