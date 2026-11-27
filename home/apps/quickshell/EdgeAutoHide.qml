import QtQuick

// Auto-hide for a bar at a screen edge. The bar is wanted while its workspace
// is empty, the pointer is on it, or something keeps it (an open card); it
// hides 300 ms after it stops being wanted. progress slides between 0 (hidden)
// and 1 (shown); a show during a running hide reverses from where it is.
Item {
    id: root

    property bool empty: true
    property bool hovered: false
    property bool keep: false

    readonly property bool wanted: empty || hovered || keep
    property bool shown: true
    property real progress: shown ? 1 : 0

    visible: false

    Component.onCompleted: if (!wanted)
        hideDelay.restart()

    onWantedChanged: {
        if (wanted) {
            hideDelay.stop();
            shown = true;
        } else {
            hideDelay.restart();
        }
    }

    Timer {
        id: hideDelay

        interval: 300
        onTriggered: root.shown = root.wanted
    }

    Behavior on progress {
        NumberAnimation {
            duration: 200
            easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
        }
    }
}
