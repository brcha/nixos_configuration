import QtQuick

// A text or icon module of the bar, with an optional tooltip
Item {
    id: button

    property alias text: label.text
    property color textColor: Theme.text
    property int fontSize: Theme.barFontSize
    property bool underline: false
    property string tooltip: ""
    property BarTooltip tooltipWindow: null
    readonly property bool hovered: hover.hovered

    signal clicked(int button)

    implicitWidth: label.implicitWidth + 2 * Theme.barModulePadding
    implicitHeight: Theme.barHeight

    Text {
        id: label

        anchors.centerIn: parent
        color: button.textColor
        font.family: Theme.font
        font.pixelSize: button.fontSize
    }

    Rectangle {
        visible: button.underline
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 2
        color: Theme.accent
    }

    HoverHandler {
        id: hover

        onHoveredChanged: {
            if (!button.tooltipWindow || !button.tooltip)
                return;
            if (hovered)
                button.tooltipWindow.show(button, button.tooltip);
            else
                button.tooltipWindow.hide(button);
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onTapped: (point, pressed) => button.clicked(pressed)
    }
}
