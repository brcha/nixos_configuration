import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

// The dock at the bottom edge of every screen: the Vicinae launcher, the pinned
// applications (DOCK_APPS, from the user's data in users/), a separator, and
// the running applications that are not pinned. A dot marks a running one.
Scope {
    id: root

    readonly property var pinned: (Quickshell.env("DOCK_APPS") || "").split(",").filter(id => id)
    readonly property var windows: ToplevelManager.toplevels.values
    readonly property var running: windows.map(w => appKey(w)).filter((key, i, keys) => keys.indexOf(key) === i)
    readonly property var unpinned: running.filter(key => !pinned.includes(key))

    // The desktop entry a window belongs to, or its app id when none matches.
    // Quickshell reads the desktop entries after it starts, and its lookups do
    // not notify; reading the entry list makes every binding that calls this
    // look again once the entries are there.
    function appKey(window): string {
        DesktopEntries.applications.values;
        return DesktopEntries.heuristicLookup(window.appId)?.id ?? window.appId;
    }

    function windowsOf(id): var {
        return windows.filter(w => appKey(w) === id);
    }

    // Through UWSM, so the application runs in a unit of its own and is not
    // stopped with quickshell.service
    function launch(id): void {
        Quickshell.execDetached(["uwsm", "app", "--", id + ".desktop"]);
    }

    // Starts the application, or focuses its window; with one of its windows
    // already focused, the next one
    function focusOrCycle(id): void {
        const list = windowsOf(id);
        if (list.length === 0) {
            launch(id);
            return;
        }
        list[(list.findIndex(w => w.activated) + 1) % list.length].activate();
    }

    component DockApp: Item {
        id: app

        required property string appId
        property BarTooltip tooltipWindow: null
        // Read again once the desktop entries are loaded (see appKey)
        readonly property var entry: {
            DesktopEntries.applications.values;
            return DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
        }
        readonly property bool isRunning: root.windowsOf(appId).length > 0

        implicitWidth: Theme.dockIconSize + 12
        implicitHeight: Theme.dockHeight

        IconImage {
            anchors.centerIn: parent
            implicitSize: Theme.dockIconSize
            source: Quickshell.iconPath(app.entry?.icon ?? "", "application-x-executable")
        }

        Rectangle {
            visible: app.isRunning
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            width: 5
            height: 5
            radius: 2.5
            color: Theme.accent
        }

        HoverHandler {
            onHoveredChanged: {
                if (hovered)
                    app.tooltipWindow?.show(app, app.entry?.name ?? app.appId);
                else
                    app.tooltipWindow?.hide(app);
            }
        }

        // Left click starts, focuses or cycles; middle click starts another instance
        TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onTapped: (point, pressed) => {
                if (pressed === Qt.LeftButton)
                    root.focusOrCycle(app.appId);
                else
                    root.launch(app.appId);
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dock

            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
            // Hidden, the dock moves down out of the window
            readonly property real slide: (1 - autoHide.progress) * height

            screen: modelData
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            implicitHeight: Theme.dockHeight
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            color: "transparent"

            WlrLayershell.namespace: "quickshell-dock"
            WlrLayershell.layer: WlrLayer.Top

            // The dock takes input where it is shown; hidden, a 2 px strip at the
            // bottom edge does, to bring it back
            mask: autoHide.shown ? dockMask : edgeMask

            Region {
                id: dockMask

                x: section.x
                width: section.width
                height: dock.height
            }

            Region {
                id: edgeMask

                y: dock.height - 2
                width: dock.width
                height: 2
            }

            // shortcut: as with the bar (see Bar.qml), the dock widening under a
            // pointer resting on the bottom edge can end this hover; the next
            // motion restores it within the hide delay
            HoverHandler {
                id: dockHover
            }

            EdgeAutoHide {
                id: autoHide

                empty: (dock.monitor?.activeWorkspace?.toplevels.values.length ?? 0) === 0
                hovered: dockHover.hovered
            }

            BarTooltip {
                id: tooltip

                anchor.window: dock
                above: true
            }

            BarSection {
                id: section

                atBottom: true
                sectionHeight: Theme.dockHeight
                x: (dock.width - width) / 2
                y: dock.slide

                // Vicinae, the same as Super+D
                BarButton {
                    implicitWidth: Theme.dockIconSize + 12
                    implicitHeight: Theme.dockHeight
                    text: ""
                    fontSize: Theme.dockIconSize * 3 / 4
                    tooltip: "Launcher (Super+D)"
                    tooltipWindow: tooltip
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            Quickshell.execDetached(["vicinae", "toggle"]);
                    }
                }

                Repeater {
                    model: root.pinned

                    DockApp {
                        required property string modelData

                        appId: modelData
                        tooltipWindow: tooltip
                    }
                }

                Rectangle {
                    visible: root.unpinned.length > 0
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    implicitWidth: 1
                    implicitHeight: Theme.dockHeight * 0.6
                    color: Theme.dim
                }

                Repeater {
                    model: root.unpinned

                    DockApp {
                        required property string modelData

                        appId: modelData
                        tooltipWindow: tooltip
                    }
                }
            }
        }
    }
}
