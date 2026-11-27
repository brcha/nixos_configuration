import QtQuick
import QtQuick.Layouts
import Quickshell

// The notification panel under the bell: quick settings, do not disturb, and
// the notification history with Clear all
BarPopup {
    id: root

    // The bar (its night light, stay awake, unit-toggle and Bluetooth state)
    // and the notification server
    property var bar: null
    property var notifications: null

    // Closes first, so a screenshot does not show the panel
    function runAfterClosing(command): void {
        close();
        pending.command = command;
        pending.restart();
    }

    Timer {
        id: pending

        property var command: []

        interval: 300
        onTriggered: Quickshell.execDetached(command)
    }

    ColumnLayout {
        width: 380
        spacing: 10

        // Night light, stay awake, Bluetooth, screenshot, sound settings
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            QuickButton {
                text: "󰖔"
                active: (root.bar?.nightLight?.class ?? "off") !== "off"
                onClicked: Quickshell.execDetached([root.bar.unitToggle, "wlsunset"])
            }
            QuickButton {
                text: "󰅶"
                active: root.bar?.stayAwake ?? false
                onClicked: Quickshell.execDetached([root.bar.unitToggle, "stay-awake"])
            }
            QuickButton {
                text: "󰂯"
                enabled: !!root.bar?.btAdapter
                active: root.bar?.btAdapter?.enabled ?? false
                onClicked: root.bar.btAdapter.enabled = !root.bar.btAdapter.enabled
            }
            QuickButton {
                text: "󰹑"
                onClicked: root.runAfterClosing(["flameshot-hyprland", "gui"])
            }
            QuickButton {
                text: "󰓃"
                onClicked: root.runAfterClosing(["pavucontrol"])
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: "Notifications"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            TextButton {
                text: root.notifications?.dnd ? "󰂛 Do not disturb" : "󰂚 Do not disturb"
                active: root.notifications?.dnd ?? false
                onClicked: root.notifications.dnd = !root.notifications.dnd
            }

            TextButton {
                visible: (root.notifications?.history.length ?? 0) > 0
                text: "Clear all"
                onClicked: root.notifications.clearAll()
            }
        }

        Text {
            visible: (root.notifications?.history.length ?? 0) === 0
            text: "No notifications"
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 12
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: Math.min(contentHeight, 420)
            visible: count > 0
            clip: true
            spacing: 6
            model: root.notifications?.history ?? []

            delegate: NotificationView {
                required property var modelData

                width: ListView.view.width
                notification: modelData
                onClosed: notification.dismiss()
                onActivated: root.close()
            }
        }
    }

    component QuickButton: Rectangle {
        id: button

        property alias text: label.text
        property bool active: false

        signal clicked

        Layout.fillWidth: true
        implicitHeight: 40
        radius: 8
        opacity: enabled ? 1 : 0.4
        color: active ? Theme.accent : buttonHover.hovered ? Qt.lighter(Theme.raised, 1.25) : Theme.raised

        Text {
            id: label

            anchors.centerIn: parent
            color: button.active ? Theme.backgroundDark : Theme.text
            font.family: Theme.font
            font.pixelSize: 20
        }

        HoverHandler {
            id: buttonHover
        }

        TapHandler {
            onTapped: button.clicked()
        }
    }

    component TextButton: Text {
        id: textButton

        property bool active: false

        signal clicked

        color: active || textHover.hovered ? Theme.accent : Theme.dim
        font.family: Theme.font
        font.pixelSize: 12

        HoverHandler {
            id: textHover
        }

        TapHandler {
            onTapped: textButton.clicked()
        }
    }
}
