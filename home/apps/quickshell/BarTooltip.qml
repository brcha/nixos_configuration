import QtQuick
import Quickshell

// One tooltip per bar window (set anchor.window), shown below the hovered item
// after a moment.
// A popup of its own: a Qt Quick ToolTip would be clipped to the bar's window.
PopupWindow {
    id: root

    property Item target: null
    property string text: ""
    // Above the window instead (the dock at the bottom edge)
    property bool above: false

    function show(item, text): void {
        visible = false;
        target = item;
        root.text = text;
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
        // Placed when it appears, since a dock icon grows and moves after the hover
        // starts. Anchored to the bar window with the item's rectangle: changing
        // anchor.item at run time crashes Quickshell 0.3.0. Above an item, it shows
        // above the window, which the dock sizes for its largest icon.
        onTriggered: {
            if (!root.target || root.text === "")
                return;
            const pos = root.target.mapToItem(null, 0, 0);
            root.anchor.rect.x = pos.x;
            root.anchor.rect.y = root.above ? 0 : pos.y;
            root.anchor.rect.width = root.target.width;
            root.anchor.rect.height = root.above ? 1 : root.target.height + 6;
            root.visible = true;
        }
    }

    anchor.edges: above ? Edges.Top : Edges.Bottom
    anchor.gravity: above ? Edges.Top : Edges.Bottom
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
