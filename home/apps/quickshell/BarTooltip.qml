import QtQuick
import Quickshell

// One tooltip per bar window (set anchor.window), shown below the hovered item
// after a moment.
// A popup of its own: a Qt Quick ToolTip would be clipped to the bar's window.
PopupWindow {
    id: root

    property Item target: null
    property string text: ""

    // Anchored to the bar window with the item's rectangle: changing anchor.item
    // at run time crashes Quickshell 0.3.0
    function show(item, text): void {
        visible = false;
        target = item;
        root.text = text;
        const pos = item.mapToItem(null, 0, 0);
        anchor.rect.x = pos.x;
        anchor.rect.y = pos.y;
        anchor.rect.width = item.width;
        anchor.rect.height = item.height + 6;
        delay.restart();
    }

    function hide(item): void {
        if (item !== target)
            return;
        delay.stop();
        visible = false;
        target = null;
    }

    Timer {
        id: delay

        interval: 500
        onTriggered: root.visible = root.target !== null && root.text !== ""
    }

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    // Near the screen edge (the power button), slide back onto the screen
    anchor.adjustment: PopupAdjustment.SlideX

    visible: false
    color: "transparent"
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 10

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.background
        border.color: Theme.accent
        border.width: 1

        Text {
            id: label

            anchors.centerIn: parent
            text: root.text
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 13
        }
    }
}
