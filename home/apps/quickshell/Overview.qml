import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Super+Tab workspace overview with live window thumbnails, and no launcher.
// It holds the keyboard while shown: Tab, Shift+Tab and the arrows select a
// window, Enter or a click switches to it, Escape or a click outside closes it.
PanelWindow {
    id: root

    property bool open: false
    // The selected window itself: its place in `windows` can change when fresh
    // positions arrive after opening
    property var selected: null
    readonly property var workspaces: Array.from(Hyprland.workspaces.values).filter(w => w.id > 0).sort((a, b) => a.id - b.id)
    // Windows in selection order: by workspace, then left to right and top to bottom
    readonly property var windows: workspaces.reduce((all, w) => all.concat(Array.from(w.toplevels.values).sort((a, b) => (a.lastIpcObject?.at?.[0] ?? 0) - (b.lastIpcObject?.at?.[0] ?? 0) || (a.lastIpcObject?.at?.[1] ?? 0) - (b.lastIpcObject?.at?.[1] ?? 0))), [])
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    // Logical size of the monitor; window positions and sizes are logical too
    readonly property real monitorWidth: (monitor?.width ?? 1920) / (monitor?.scale || 1)
    readonly property real monitorHeight: (monitor?.height ?? 1080) / (monitor?.scale || 1)

    function show(): void {
        screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0];
        // Fresh window positions and sizes; the cards follow when they arrive
        Hyprland.refreshToplevels();
        selected = windows.indexOf(Hyprland.activeToplevel) >= 0 ? Hyprland.activeToplevel : null;
        open = true;
    }

    function close(): void {
        open = false;
    }

    function focusWindow(toplevel: HyprlandToplevel): void {
        close();
        if (toplevel?.address)
            Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${toplevel.address}" })`);
    }

    function step(delta: int): void {
        if (windows.length === 0)
            return;
        const i = windows.indexOf(selected);
        selected = windows[i < 0 ? (delta > 0 ? 0 : windows.length - 1) : (i + delta + windows.length) % windows.length];
    }

    GlobalShortcut {
        name: "overview"
        onPressed: root.open ? root.close() : root.show()
    }

    visible: open
    color: Qt.alpha(Theme.backgroundDark, 0.85)

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // A click outside the workspace cards closes the overview
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                root.close();
                break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
                if (root.selected)
                    root.focusWindow(root.selected);
                break;
            case Qt.Key_Tab:
                // Shift+Tab usually arrives as Backtab, but not from every keyboard
                root.step(event.modifiers & Qt.ShiftModifier ? -1 : 1);
                break;
            case Qt.Key_Right:
            case Qt.Key_Down:
                root.step(1);
                break;
            case Qt.Key_Backtab:
            case Qt.Key_Left:
            case Qt.Key_Up:
                root.step(-1);
                break;
            default:
                return;
            }
            // Accepted, so Qt does not use Tab for focus navigation
            event.accepted = true;
        }

        Flow {
            id: flow

            readonly property real cardWidth: root.monitorWidth / 5
            readonly property int perRow: Math.max(1, Math.floor((root.width - 128 + spacing) / (cardWidth + spacing)))

            anchors.centerIn: parent
            width: Math.min(root.workspaces.length, perRow) * (cardWidth + spacing) - spacing
            spacing: 24

            Repeater {
                // Thumbnails capture their windows, so none may exist while hidden
                model: root.open ? root.workspaces : []

                Column {
                    id: workspace

                    required property HyprlandWorkspace modelData

                    spacing: 6

                    Text {
                        text: workspace.modelData.name
                        color: workspace.modelData.active ? Theme.text : Theme.dim
                        font.family: Theme.font
                        font.pixelSize: 13
                    }

                    Rectangle {
                        id: card

                        // Workspace pixels to card pixels
                        readonly property real ratio: width / root.monitorWidth

                        width: flow.cardWidth
                        height: root.monitorHeight * ratio
                        radius: 8
                        color: Theme.background
                        // The accent marks the selected window, which may fill the card
                        border.color: workspace.modelData.active ? Theme.dim : Theme.raised
                        border.width: 2
                        clip: true

                        // A click on an empty part switches to the workspace
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.close();
                                workspace.modelData.activate();
                            }
                        }

                        Repeater {
                            model: workspace.modelData.toplevels

                            WindowThumb {
                                id: thumb

                                required property HyprlandToplevel modelData
                                readonly property var ipc: modelData.lastIpcObject
                                readonly property HyprlandMonitor monitor: workspace.modelData.monitor ?? root.monitor

                                toplevel: modelData
                                x: ((ipc?.at?.[0] ?? 0) - (monitor?.x ?? 0)) * card.ratio
                                y: ((ipc?.at?.[1] ?? 0) - (monitor?.y ?? 0)) * card.ratio
                                width: (ipc?.size?.[0] ?? 0) * card.ratio
                                height: (ipc?.size?.[1] ?? 0) * card.ratio
                                radius: 4

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.focusWindow(thumb.modelData)
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    visible: root.selected === thumb.modelData
                                    color: "transparent"
                                    radius: 4
                                    border.color: Theme.accent
                                    border.width: 2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
