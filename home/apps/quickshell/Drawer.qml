import QtQuick
import QtQuick.Layouts

// A hover drawer of the bar: the leader icon stays, and hovering it for 200 ms
// slides the other modules out to its left, so the leader stays under the
// pointer at the right end of the bar. Leaving the drawer closes it, unless a
// click on the leader pinned it; another click unpins it.
Item {
    id: root

    property alias leaderText: leader.text
    property alias leaderColor: leader.textColor
    property alias leaderTooltip: leader.tooltip
    property BarTooltip tooltipWindow: null
    default property alias content: row.data

    property bool pinned: false
    // Held open from outside, for example while a tray menu is open
    property bool keepOpen: false
    readonly property bool expanded: pinned || open || keepOpen
    property bool open: false

    function togglePin(): void {
        pinned = !pinned;
        if (pinned)
            open = true;
    }

    implicitWidth: slide.width + leader.implicitWidth
    implicitHeight: Theme.barHeight

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                reveal.restart();
            } else {
                reveal.stop();
                root.open = false;
            }
        }
    }

    Timer {
        id: reveal

        interval: 200
        onTriggered: root.open = true
    }

    Item {
        id: slide

        width: root.expanded ? row.implicitWidth : 0
        height: parent.height
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.right: parent.right
            width: row.implicitWidth
            height: parent.height
            color: Theme.raised

            RowLayout {
                id: row

                height: parent.height
                spacing: 0
            }
        }
    }

    BarButton {
        id: leader

        x: slide.width
        tooltipWindow: root.tooltipWindow
        onClicked: pressed => {
            if (pressed === Qt.LeftButton)
                root.togglePin();
        }
    }

    // Grey while open, accent while pinned
    Rectangle {
        visible: root.expanded
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 2
        color: root.pinned ? Theme.accent : Theme.dim
    }
}
