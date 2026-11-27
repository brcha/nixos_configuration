import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// The dock at the bottom edge of every screen: the Vicinae launcher, the pinned
// applications, a separator, and the running applications that are not pinned,
// with a dot per window, up to three. Icons near the pointer grow; icons can be
// dragged to a new place, and a running one dragged among the pinned ones is
// pinned. A right click opens the application's menu, a card that grows out of
// the dock.
Scope {
    id: root

    // The user's list in users/ (DOCK_APPS) seeds the state file on a fresh
    // profile; after that the file holds the pinned list
    readonly property var seed: (Quickshell.env("DOCK_APPS") || "").split(",").filter(id => id)
    property var pinned: seed
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

    function setPinned(list): void {
        pinned = list;
        dockState.pinned = list;
        stateFile.writeAdapter();
    }

    function movePinned(from, to): void {
        const list = pinned.slice();
        list.splice(to, 0, ...list.splice(from, 1));
        setPinned(list);
    }

    function pin(id, at): void {
        if (pinned.includes(id))
            return;
        const list = pinned.slice();
        list.splice(at, 0, id);
        setPinned(list);
    }

    function unpin(id): void {
        setPinned(pinned.filter(p => p !== id));
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

    FileView {
        id: stateFile

        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell/dock.json"
        // Missing on a fresh profile, which is expected
        printErrors: false
        onLoaded: root.pinned = Array.from(dockState.pinned)
        // Written once the failed read has finished
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                Qt.callLater(root.setPinned, root.seed);
        }

        JsonAdapter {
            id: dockState

            property list<string> pinned: []
        }
    }

    component DockApp: Item {
        id: app

        required property string appId
        property BarTooltip tooltipWindow: null
        property real size: Theme.dockIconSize
        // Moves the icon off its place while it, or one next to it, is dragged
        property real shift: 0
        // Read again once the desktop entries are loaded (see appKey)
        readonly property var entry: {
            DesktopEntries.applications.values;
            return DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
        }
        readonly property int windowCount: root.windowsOf(appId).length

        signal dragStarted
        signal dragMoved(real dx)
        signal dragEnded
        signal menuRequested

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

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                spacing: 3

                Repeater {
                    model: Math.min(3, app.windowCount)

                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: Theme.accent
                    }
                }
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

            // Left click starts, focuses or cycles; middle click starts another
            // instance; right click opens the menu
            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onTapped: (point, pressed) => {
                    if (pressed === Qt.LeftButton) {
                        root.focusOrCycle(app.appId);
                    } else if (pressed === Qt.MiddleButton) {
                        root.launch(app.appId);
                    } else {
                        app.tooltipWindow?.hide(face);
                        app.menuRequested();
                    }
                }
            }
        }
    }

    component MenuRow: Item {
        id: row

        property string text: ""
        property bool dim: false

        signal activated

        Layout.fillWidth: true
        implicitWidth: label.implicitWidth + 20
        implicitHeight: 30

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: rowHover.hovered ? Theme.raised : "transparent"
        }

        Text {
            id: label

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: row.text
            elide: Text.ElideRight
            color: row.dim ? Theme.dim : Theme.text
            font.family: Theme.font
            font.pixelSize: 13
        }

        HoverHandler {
            id: rowHover
        }

        TapHandler {
            onTapped: row.activated()
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
            property real magnify: dockHover.hovered && autoHide.shown && dragKind === "" && menuApp === "" ? 1 : 0
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

            // Dragging: the icon at dragIndex of the pinned or unpinned group
            // (dragKind) follows the pointer by dragDx, and the icons it passes make
            // room for it. A pinned icon moves to the pinned index dragTo; a running
            // one dropped left of the separator is pinned at dragTo (otherwise -1).
            property string dragKind: ""
            property int dragIndex: -1
            property real dragDx: 0
            readonly property int dragTo: {
                if (dragKind === "pinned")
                    return Math.max(0, Math.min(pinnedCount - 1, dragIndex + Math.round(dragDx / slot)));
                if (dragKind !== "unpinned")
                    return -1;
                const middle = baseLeft(1 + pinnedCount + dragIndex) + slot / 2 + dragDx;
                if (middle >= baseRowX + (1 + pinnedCount) * slot + separatorWidth / 2)
                    return -1;
                return Math.max(0, Math.min(pinnedCount, Math.floor((middle - baseLeft(1)) / slot + 0.5)));
            }

            // The application whose menu is open; menuFor stays set while the menu
            // slides shut
            property string menuApp: ""
            property string menuFor: ""
            property Item menuIcon: null
            property real menuReveal: menuApp !== "" ? 1 : 0
            readonly property var menuWindows: menuFor !== "" ? root.windowsOf(menuFor) : []
            readonly property real menuWidth: Math.max(180, Math.min(360, menuColumn.implicitWidth + 2 * 8))
            readonly property real menuHeight: menuColumn.implicitHeight + 2 * 8
            // Centred over its icon, kept on the screen, and snapped to an end of
            // the dock when it comes within a corner of it
            readonly property var menuPlace: {
                const b0 = section.x + section.bodyX, b1 = b0 + section.bodyWidth, r = Theme.barRadius;
                const middle = menuIcon ? icons.x + menuIcon.x + menuIcon.width / 2 : (b0 + b1) / 2;
                let x = Math.max(0, Math.min(width - menuWidth, middle - menuWidth / 2));
                if (Math.abs(x - b0) < r)
                    x = b0;
                else if (Math.abs(x + menuWidth - b1) < r)
                    x = b1 - menuWidth;
                return { x, b0, b1, atLeft: false, atRight: false };
            }

            // Slot 0 is the launcher, then the pinned icons, the separator and the rest
            function baseLeft(k): real {
                return baseRowX + k * slot + (k > pinnedCount ? separatorWidth : 0);
            }

            function pinnedShift(i): real {
                if (dragKind === "pinned") {
                    if (i === dragIndex)
                        return dragDx;
                    if (dragIndex < i && i <= dragTo)
                        return -slot;
                    if (dragTo <= i && i < dragIndex)
                        return slot;
                }
                if (dragKind === "unpinned" && dragTo >= 0 && i >= dragTo)
                    return slot;
                return 0;
            }

            function unpinnedShift(i): real {
                if (dragKind !== "unpinned")
                    return 0;
                if (i === dragIndex)
                    return dragDx;
                return dragTo >= 0 && i < dragIndex ? slot : 0;
            }

            function startDrag(kind, index): void {
                dragDx = 0;
                dragIndex = index;
                dragKind = kind;
            }

            // Later: the change recreates the dragged delegate
            function endDrag(appId): void {
                const kind = dragKind, from = dragIndex, to = dragTo;
                dragKind = "";
                if (kind === "pinned" && to !== from)
                    Qt.callLater(root.movePinned, from, to);
                else if (kind === "unpinned" && to >= 0)
                    Qt.callLater(root.pin, appId, to);
            }

            function toggleMenu(appId, icon): void {
                if (menuApp === appId) {
                    menuApp = "";
                    return;
                }
                menuIcon = icon;
                menuFor = appId;
                menuApp = appId;
                menuColumn.forceActiveFocus();
            }

            Behavior on magnify {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on menuReveal {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            onMenuRevealChanged: if (menuReveal === 0)
                menuFor = ""

            screen: modelData
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            // Room for the magnified icons from the start, so only they animate;
            // grown once more while a menu shows
            implicitHeight: Math.max(Theme.dockHeight + Theme.dockMagnifiedSize - Theme.dockIconSize, menuFor !== "" ? Theme.dockHeight + menuHeight + Theme.barFillet : 0)
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            color: "transparent"

            WlrLayershell.namespace: "quickshell-dock"
            WlrLayershell.layer: WlrLayer.Top
            // Esc closes the menu
            WlrLayershell.keyboardFocus: menuApp !== "" ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            HyprlandFocusGrab {
                windows: [dock]
                active: dock.menuApp !== ""
                onCleared: dock.menuApp = ""
            }

            // The dock takes input where it is shown, above it while icons are
            // magnified, and on its menu; hidden, a 2 px strip at the bottom edge
            // does, to bring it back
            mask: autoHide.shown ? dockMask : edgeMask

            Region {
                id: dockMask

                x: section.x
                y: dock.magnify > 0 ? 0 : dock.height - Theme.dockHeight
                width: section.width
                height: dock.height - y

                Region {
                    x: dock.menuPlace.x
                    y: section.y - dock.menuHeight
                    width: dock.menuFor !== "" ? dock.menuWidth : 0
                    height: dock.menuFor !== "" ? dock.menuHeight : 0
                }
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
                keep: dock.dragKind !== "" || dock.menuApp !== ""
            }

            BarTooltip {
                id: tooltip

                anchor.window: dock
                above: true
            }

            // Under the section, which it slides out from
            CardFrame {
                visible: dock.menuFor !== ""
                atBottom: true
                y: section.y - dock.menuHeight - Theme.barFillet
                width: dock.width
                place: dock.menuPlace
                cardWidth: dock.menuWidth
                cardHeight: dock.menuHeight
                reveal: dock.menuReveal

                ColumnLayout {
                    id: menuColumn

                    x: 8
                    y: 8
                    width: dock.menuWidth - 2 * 8
                    spacing: 0
                    Keys.onEscapePressed: dock.menuApp = ""

                    Repeater {
                        model: dock.menuWindows

                        MenuRow {
                            required property var modelData

                            text: modelData.title || modelData.appId
                            onActivated: {
                                modelData.activate();
                                dock.menuApp = "";
                            }
                        }
                    }

                    Rectangle {
                        visible: dock.menuWindows.length > 0
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        implicitHeight: 1
                        color: Theme.raised
                    }

                    MenuRow {
                        text: "New window"
                        onActivated: {
                            root.launch(dock.menuFor);
                            dock.menuApp = "";
                        }
                    }

                    MenuRow {
                        text: root.pinned.includes(dock.menuFor) ? "Unpin" : "Pin"
                        onActivated: {
                            if (root.pinned.includes(dock.menuFor))
                                root.unpin(dock.menuFor);
                            else
                                root.pin(dock.menuFor, root.pinned.length);
                            dock.menuApp = "";
                        }
                    }

                    MenuRow {
                        visible: dock.menuWindows.length > 0
                        text: dock.menuWindows.length > 1 ? "Close all windows" : "Close"
                        onActivated: {
                            dock.menuWindows.forEach(w => w.close());
                            dock.menuApp = "";
                        }
                    }
                }
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
                height: Theme.dockHeight + Theme.dockMagnifiedSize - Theme.dockIconSize
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
                        id: pinnedApp

                        required property string modelData
                        required property int index

                        appId: modelData
                        tooltipWindow: tooltip
                        size: dock.sizes[1 + index] ?? Theme.dockIconSize
                        shift: dock.pinnedShift(index)
                        onDragStarted: dock.startDrag("pinned", index)
                        onDragMoved: dx => dock.dragDx = dx
                        onDragEnded: dock.endDrag(appId)
                        onMenuRequested: dock.toggleMenu(appId, pinnedApp)
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
                    transform: Translate {
                        x: dock.dragKind === "unpinned" && dock.dragTo >= 0 ? dock.slot : 0

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Repeater {
                    model: root.unpinned

                    DockApp {
                        id: runningApp

                        required property string modelData
                        required property int index

                        appId: modelData
                        tooltipWindow: tooltip
                        size: dock.sizes[1 + dock.pinnedCount + index] ?? Theme.dockIconSize
                        shift: dock.unpinnedShift(index)
                        onDragStarted: dock.startDrag("unpinned", index)
                        onDragMoved: dx => dock.dragDx = dx
                        onDragEnded: dock.endDrag(appId)
                        onMenuRequested: dock.toggleMenu(appId, runningApp)
                    }
                }
            }
        }
    }
}
