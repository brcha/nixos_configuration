import QtQuick
import QtQuick.Layouts

// A hover drawer of the bar: the leader icon stays in its section, and hovering
// it for 200 ms opens a card under it with the other modules, growing out of
// the section. The bar moves panel into that card and draws it from reveal.
// Leaving the leader and the card closes it after a moment, unless a click on
// the leader pinned it; another click unpins it.
Item {
    id: root

    property alias leaderText: leaderButton.text
    property alias leaderColor: leaderButton.textColor
    property alias leaderTooltip: leaderButton.tooltip
    property BarTooltip tooltipWindow: null
    default property alias content: row.data

    property bool pinned: false
    // Held open from outside, for example while a tray menu is open
    property bool keepOpen: false
    property bool open: false
    readonly property bool expanded: pinned || open || keepOpen
    // 0 shut, 1 open; animated, so the card stays until it has slid shut
    property real reveal: expanded ? 1 : 0
    readonly property alias leader: leaderButton
    readonly property alias panel: panelItem

    function togglePin(): void {
        pinned = !pinned;
        if (pinned)
            open = true;
    }

    function hoverChanged(): void {
        if (leaderHover.hovered || panelHover.hovered) {
            closeDelay.stop();
            if (!open)
                openDelay.restart();
        } else {
            openDelay.stop();
            closeDelay.restart();
        }
    }

    Behavior on reveal {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    implicitWidth: leaderButton.implicitWidth
    implicitHeight: Theme.barHeight

    HoverHandler {
        id: leaderHover

        onHoveredChanged: root.hoverChanged()
    }

    Timer {
        id: openDelay

        interval: 200
        onTriggered: root.open = true
    }

    // Time to move from the leader into the card
    Timer {
        id: closeDelay

        interval: 250
        onTriggered: root.open = false
    }

    BarButton {
        id: leaderButton

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

    // Shown once the bar has moved it into the card
    Item {
        id: panelItem

        visible: parent !== root
        width: row.implicitWidth
        height: Theme.barHeight

        RowLayout {
            id: row

            height: parent.height
            spacing: 0
        }

        HoverHandler {
            id: panelHover

            onHoveredChanged: root.hoverChanged()
        }
    }
}
