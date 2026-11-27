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

        // Night light, stay awake, Bluetooth, screenshot
        // Above the rows below, which the buttons' tooltips overlap
        RowLayout {
            z: 1
            Layout.fillWidth: true
            spacing: 6

            QuickButton {
                text: "󰖔"
                tip: root.bar?.nightLight?.tooltip ?? "Night light"
                active: (root.bar?.nightLight?.class ?? "off") !== "off"
                onClicked: Quickshell.execDetached([root.bar.unitToggle, "wlsunset"])
            }
            QuickButton {
                text: "󰅶"
                tip: root.bar?.stayAwake ? "Staying awake: no lock, no screen-off" : "Idle timers active (lock after 10 min)"
                active: root.bar?.stayAwake ?? false
                onClicked: Quickshell.execDetached([root.bar.unitToggle, "stay-awake"])
            }
            // A right click opens the Bluetooth settings
            QuickButton {
                readonly property var connected: root.bar?.btAdapter?.devices.values.filter(d => d.connected) ?? []

                text: "󰂯"
                tip: `Bluetooth: ${active ? "on" : "off"}${connected.length > 0 ? "\n" + connected.map(d => d.name).join("\n") : ""}\nRight click: Bluetooth settings`
                enabled: !!root.bar?.btAdapter
                active: root.bar?.btAdapter?.enabled ?? false
                onClicked: root.bar.btAdapter.enabled = !root.bar.btAdapter.enabled
                onRightClicked: root.runAfterClosing(["kcmshell6", "kcm_bluetooth"])
            }
            QuickButton {
                text: "󰹑"
                tip: "Screenshot (Flameshot)"
                onClicked: root.runAfterClosing(["flameshot-hyprland", "gui"])
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
        property string tip: ""
        property bool active: false

        signal clicked
        signal rightClicked

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

            onHoveredChanged: hovered ? tipDelay.restart() : tipDelay.stop()
        }

        Timer {
            id: tipDelay

            interval: 500
        }

        // Below the button, kept inside the row
        Rectangle {
            visible: buttonHover.hovered && !tipDelay.running && button.tip !== ""
            x: Math.max(-button.x, Math.min((button.width - width) / 2, button.parent.width - button.x - width))
            y: button.height + 4
            width: tipLabel.implicitWidth + 16
            height: tipLabel.implicitHeight + 10
            radius: 6
            color: Theme.background
            border.color: Theme.accent
            border.width: 1

            Text {
                id: tipLabel

                anchors.centerIn: parent
                text: button.tip
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 13
            }
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: (point, pressed) => pressed === Qt.RightButton ? button.rightClicked() : button.clicked()
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
