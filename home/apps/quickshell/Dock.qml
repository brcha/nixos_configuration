import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

// The dock at the bottom edge of every screen: the Vicinae launcher, the pinned
// applications (DOCK_APPS, from the user's data in users/), a separator, and
// the running applications that are not pinned. A dot marks a running one.
// Icons near the pointer grow; pinned icons can be dragged to a new place.
Scope {
    id: root

    property var pinned: (Quickshell.env("DOCK_APPS") || "").split(",").filter(id => id)
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

    function movePinned(from, to): void {
        const list = pinned.slice();
        list.splice(to, 0, ...list.splice(from, 1));
        pinned = list;
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
        property real size: Theme.dockIconSize
        // Pinned icons can be dragged; shift moves the icon off its place meanwhile
        property bool draggable: false
        property real shift: 0
        // Read again once the desktop entries are loaded (see appKey)
        readonly property var entry: {
            DesktopEntries.applications.values;
            return DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
        }
        readonly property bool isRunning: root.windowsOf(appId).length > 0

        signal dragStarted
        signal dragMoved(real dx)
        signal dragEnded

        implicitWidth: size + 12
        implicitHeight: Theme.dockHeight + Theme.dockMagnifiedSize - Theme.dockIconSize

        // Grows upwards out of the dock with the icon, so the magnified part
        // takes clicks and the tooltip shows above it
        Item {
            id: face

            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.dockHeight + app.size - Theme.dockIconSize
            transform: Translate {
                x: app.shift

                Behavior on x {
                    enabled: !drag.active

                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            IconImage {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (Theme.dockHeight - Theme.dockIconSize) / 2
                implicitSize: app.size
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
                        app.tooltipWindow?.show(face, app.entry?.name ?? app.appId);
                    else
                        app.tooltipWindow?.hide(face);
                }
            }

            DragHandler {
                id: drag

                enabled: app.draggable
                target: null
                yAxis.enabled: false
                onActiveChanged: {
                    if (active) {
                        app.tooltipWindow?.hide(face);
                        app.dragStarted();
                    } else {
                        app.dragEnded();
                    }
                }
                onActiveTranslationChanged: if (active)
                    app.dragMoved(activeTranslation.x)
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
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dock

            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
            // Hidden, the dock moves down out of the window
            readonly property real slide: (1 - autoHide.progress) * height

            // Magnification. Every icon's size comes from the pointer's distance to
            // where the icon sits unmagnified, which does not move; the section is
            // then shifted so that the point under the pointer stays under it.
            readonly property real slot: Theme.dockIconSize + 12
            readonly property real separatorWidth: separator.visible ? separator.implicitWidth + separator.Layout.leftMargin + separator.Layout.rightMargin : 0
            readonly property int pinnedCount: root.pinned.length
            readonly property int slots: 1 + pinnedCount + root.unpinned.length
            readonly property real baseRowX: (width - slots * slot - separatorWidth) / 2
            // Window x of the pointer, kept while magnification fades out
            property real pointerX: 0
            // 0 to 1: how much the icons near the pointer grow
            property real magnify: dockHover.hovered && autoHide.shown && dragFrom < 0 ? 1 : 0
            readonly property var sizes: {
                const sizes = [], range = 3 * slot;
                for (let k = 0; k < slots; k++) {
                    const d = Math.abs(pointerX - baseLeft(k) - slot / 2);
                    const near = d < range ? (1 + Math.cos(Math.PI * d / range)) / 2 : 0;
                    sizes.push(Theme.dockIconSize + (Theme.dockMagnifiedSize - Theme.dockIconSize) * magnify * near);
                }
                return sizes;
            }
            readonly property real shift: {
                let shift = 0;
                for (let k = 0; k < slots; k++)
                    shift += (sizes[k] - Theme.dockIconSize) * Math.max(0, Math.min(1, (pointerX - baseLeft(k)) / slot));
                return shift;
            }

            // Reordering: the pinned icon at dragFrom follows the pointer by dragDx
            // and the ones between make room for it at dragTo
            property int dragFrom: -1
            property real dragDx: 0
            readonly property int dragTo: Math.max(0, Math.min(pinnedCount - 1, dragFrom + Math.round(dragDx / slot)))

            // Slot 0 is the launcher, then the pinned icons, the separator and the rest
            function baseLeft(k): real {
                return baseRowX + k * slot + (k > pinnedCount ? separatorWidth : 0);
            }

            function pinnedShift(i): real {
                if (dragFrom < 0)
                    return 0;
                if (i === dragFrom)
                    return dragDx;
                if (dragFrom < i && i <= dragTo)
                    return -slot;
                if (dragTo <= i && i < dragFrom)
                    return slot;
                return 0;
            }

            Behavior on magnify {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            screen: modelData
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            // Room for the magnified icons from the start, so only they animate
            implicitHeight: Theme.dockHeight + Theme.dockMagnifiedSize - Theme.dockIconSize
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            color: "transparent"

            WlrLayershell.namespace: "quickshell-dock"
            WlrLayershell.layer: WlrLayer.Top

            // The dock takes input where it is shown, and above it while icons are
            // magnified; hidden, a 2 px strip at the bottom edge does, to bring it back
            mask: autoHide.shown ? dockMask : edgeMask

            Region {
                id: dockMask

                x: section.x
                y: dock.magnify > 0 ? 0 : dock.height - Theme.dockHeight
                width: section.width
                height: dock.height - y
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

                onPointChanged: if (hovered)
                    dock.pointerX = point.position.x
            }

            EdgeAutoHide {
                id: autoHide

                empty: (dock.monitor?.activeWorkspace?.toplevels.values.length ?? 0) === 0
                hovered: dockHover.hovered
                keep: dock.dragFrom >= 0
            }

            BarTooltip {
                id: tooltip

                anchor.window: dock
                above: true
            }

            // Only the background: the icons sit in a row of their own over it, as
            // tall as the window, so that the magnified part of an icon lies inside
            // its item and takes clicks
            BarSection {
                id: section

                atBottom: true
                sectionHeight: Theme.dockHeight
                x: dock.baseRowX - bodyX - Theme.barPadding - dock.shift
                y: dock.height - Theme.dockHeight + dock.slide

                Item {
                    implicitWidth: icons.implicitWidth
                    implicitHeight: Theme.dockHeight
                }
            }

            RowLayout {
                id: icons

                x: section.x + section.bodyX + Theme.barPadding
                y: section.y + Theme.dockHeight - height
                height: dock.height
                spacing: 0

                // Vicinae, the same as Super+D; it grows upwards like the icons
                Item {
                    implicitWidth: dock.sizes[0] + 12
                    implicitHeight: icons.height

                    BarButton {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Theme.dockHeight + dock.sizes[0] - Theme.dockIconSize
                        text: ""
                        fontSize: dock.sizes[0] * 3 / 4
                        tooltip: "Launcher (Super+D)"
                        tooltipWindow: tooltip
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                Quickshell.execDetached(["vicinae", "toggle"]);
                        }
                    }
                }

                Repeater {
                    model: root.pinned

                    DockApp {
                        required property string modelData
                        required property int index

                        appId: modelData
                        tooltipWindow: tooltip
                        size: dock.sizes[1 + index] ?? Theme.dockIconSize
                        draggable: true
                        shift: dock.pinnedShift(index)
                        onDragStarted: {
                            dock.dragDx = 0;
                            dock.dragFrom = index;
                        }
                        onDragMoved: dx => dock.dragDx = dx
                        // Later: the move recreates this delegate
                        onDragEnded: {
                            const from = dock.dragFrom, to = dock.dragTo;
                            dock.dragFrom = -1;
                            if (from >= 0 && to !== from)
                                Qt.callLater(root.movePinned, from, to);
                        }
                    }
                }

                Rectangle {
                    id: separator

                    visible: root.unpinned.length > 0
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: Theme.dockHeight * 0.2
                    implicitWidth: 1
                    implicitHeight: Theme.dockHeight * 0.6
                    color: Theme.dim
                }

                Repeater {
                    model: root.unpinned

                    DockApp {
                        required property string modelData
                        required property int index

                        appId: modelData
                        tooltipWindow: tooltip
                        size: dock.sizes[1 + dock.pinnedCount + index] ?? Theme.dockIconSize
                    }
                }
            }
        }
    }
}
