import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

// Alt+Tab window switcher, most recently used first. Hyprland binds drive it
// through global shortcuts, so it never takes keyboard focus: Tab and Shift+Tab
// move the selection, releasing Alt switches, Alt+Escape cancels.
PanelWindow {
    id: root

    property bool open: false
    property var windows: []
    property int index: 0
    // Window addresses, most recently focused first
    property var recent: []

    // Windows on normal workspaces in the order of `recent`; windows not focused
    // since Quickshell started follow in Hyprland's focus history order
    function snapshot(): var {
        const rank = address => {
            const i = recent.indexOf(address);
            return i < 0 ? recent.length : i;
        };
        const history = t => t.lastIpcObject?.focusHistoryID ?? Number.MAX_SAFE_INTEGER;
        return Array.from(Hyprland.toplevels.values).filter(t => (t.workspace?.id ?? 0) > 0).sort((a, b) => rank(a.address) - rank(b.address) || history(a) - history(b));
    }

    function step(delta: int): void {
        if (open) {
            index = (index + delta + windows.length) % windows.length;
            return;
        }
        const list = snapshot();
        if (list.length === 0)
            return;
        recent = recent.filter(address => list.some(t => t.address === address));
        windows = list;
        index = delta > 0 ? Math.min(1, list.length - 1) : list.length - 1;
        screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0];
        open = true;
    }

    function finish(): void {
        if (!open)
            return;
        const address = windows[index]?.address;
        cancel();
        if (address)
            Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${address}" })`);
    }

    function cancel(): void {
        open = false;
        windows = [];
    }

    // Without it, Quickshell lists no windows until the first window event
    Component.onCompleted: Hyprland.refreshToplevels()

    Connections {
        target: Hyprland

        function onActiveToplevelChanged(): void {
            const address = Hyprland.activeToplevel?.address;
            if (address)
                root.recent = [address, ...root.recent.filter(a => a !== address)];
        }
    }

    // A press bind reaches its shortcut as pressed (and released on its key-up);
    // the release binds on Alt reach theirs only as released
    GlobalShortcut {
        name: "switcher-next"
        onPressed: root.step(1)
    }
    GlobalShortcut {
        name: "switcher-prev"
        onPressed: root.step(-1)
    }
    GlobalShortcut {
        name: "switcher-end"
        onReleased: root.finish()
    }
    GlobalShortcut {
        name: "switcher-cancel"
        onPressed: root.cancel()
    }

    visible: open
    color: "transparent"
    implicitWidth: panel.width
    implicitHeight: panel.height

    // No anchors: centred on the screen
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        id: panel

        width: list.width + 2 * Theme.padding
        height: list.height + 2 * Theme.padding
        radius: 12
        color: Qt.alpha(Theme.backgroundDark, 0.9)
        border.color: Theme.raised
        border.width: 1

        ListView {
            id: list

            readonly property int cardWidth: 256

            x: Theme.padding
            y: Theme.padding
            width: Math.min(contentWidth, (root.screen?.width ?? 1920) - 128)
            height: 212
            orientation: ListView.Horizontal
            spacing: 12
            interactive: false
            model: root.windows
            currentIndex: root.index
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Rectangle {
                id: card

                required property HyprlandToplevel modelData
                required property int index
                readonly property bool selected: index === root.index

                width: list.cardWidth
                height: list.height
                radius: 10
                color: selected ? Theme.raised : Theme.background
                border.color: selected ? Theme.accent : Theme.raised
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    WindowThumb {
                        id: thumb

                        toplevel: card.modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        spacing: 6

                        IconImage {
                            implicitSize: 16
                            source: thumb.icon
                        }
                        Text {
                            Layout.fillWidth: true
                            text: card.modelData?.title ?? ""
                            elide: Text.ElideRight
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 13
                        }
                        Text {
                            text: card.modelData?.workspace?.name ?? ""
                            color: Theme.dim
                            font.family: Theme.font
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
}
