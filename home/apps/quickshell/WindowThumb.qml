import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

// Live picture of a window, fitted into the item; its icon until the first frame
Rectangle {
    id: root

    required property HyprlandToplevel toplevel
    readonly property string icon: Quickshell.iconPath(DesktopEntries.heuristicLookup(toplevel?.wayland?.appId ?? "")?.icon ?? "", "application-x-executable")
    readonly property real aspect: view.sourceSize.height > 0 ? view.sourceSize.width / view.sourceSize.height : 16 / 9

    color: Theme.raised
    radius: 6
    clip: true

    ScreencopyView {
        id: view

        anchors.centerIn: parent
        width: Math.min(root.width, root.height * root.aspect)
        height: width / root.aspect
        captureSource: root.toplevel?.wayland ?? null
        live: true
        paintCursor: false
    }

    IconImage {
        anchors.centerIn: parent
        visible: !view.hasContent
        implicitSize: Math.min(root.width, root.height) / 2
        source: root.icon
    }
}
