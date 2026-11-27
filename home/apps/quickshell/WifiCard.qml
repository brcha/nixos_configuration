import QtQuick
// The Basic style: under the KDE platform theme Qt picks the Breeze style, which
// needs Kirigami and does not take a custom background
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

// Wi-Fi networks from NetworkManager: a click connects (asking for the password
// of a secured network not joined before) or, on the connected one, disconnects
BarPopup {
    id: root

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: Array.from(device?.networks.values ?? []).sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
    // The network whose password is being asked for, and the last failure
    property var asking: null
    property string failure: ""

    function pick(network): void {
        failure = "";
        if (network.connected) {
            network.disconnect();
        } else if (network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe) {
            asking = null;
            network.connect();
        } else {
            ask(network);
        }
    }

    function ask(network): void {
        asking = network;
        password.text = "";
        password.forceActiveFocus();
    }

    onOpened: {
        asking = null;
        failure = "";
    }

    // Scan only while the card shows
    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.open
        when: root.device !== null
    }

    ColumnLayout {
        width: 300
        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "Wi-Fi"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            Text {
                text: Networking.wifiEnabled ? "On" : "Off"
                color: Networking.wifiEnabled ? Theme.accent : Theme.dim
                font.family: Theme.font
                font.pixelSize: 13

                TapHandler {
                    onTapped: Networking.wifiEnabled = !Networking.wifiEnabled
                }
            }
        }

        Text {
            visible: Networking.wifiEnabled && root.networks.length === 0
            text: "Looking for networks…"
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 12
        }

        Repeater {
            model: Networking.wifiEnabled ? root.networks : []

            Item {
                id: row

                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 30

                Connections {
                    target: row.modelData

                    function onConnectionFailed(reason): void {
                        if (reason === ConnectionFailReason.NoSecrets)
                            root.ask(row.modelData);
                        else
                            root.failure = `${row.modelData.name}: ${ConnectionFailReason.toString(reason)}`;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: rowHover.hovered ? Theme.raised : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Text {
                        text: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"][Math.min(4, Math.floor(row.modelData.signalStrength * 5))]
                        color: row.modelData.connected ? Theme.accent : Theme.text
                        font.family: Theme.font
                        font.pixelSize: 16
                    }

                    Text {
                        Layout.fillWidth: true
                        text: row.modelData.name
                        elide: Text.ElideRight
                        color: row.modelData.connected ? Theme.accent : Theme.text
                        font.family: Theme.font
                        font.pixelSize: 13
                    }

                    Text {
                        text: row.modelData.stateChanging ? "…" : row.modelData.connected ? "Disconnect" : ""
                        color: Theme.dim
                        font.family: Theme.font
                        font.pixelSize: 11
                    }

                    Text {
                        visible: row.modelData.security !== WifiSecurityType.Open && row.modelData.security !== WifiSecurityType.Owe
                        text: "󰌾"
                        color: Theme.dim
                        font.family: Theme.font
                        font.pixelSize: 13
                    }
                }

                HoverHandler {
                    id: rowHover
                }

                TapHandler {
                    onTapped: root.pick(row.modelData)
                }
            }
        }

        // The password of the network being joined; Enter connects, Esc closes the card
        TextField {
            id: password

            visible: root.asking !== null
            Layout.fillWidth: true
            placeholderText: root.asking ? `Password for ${root.asking.name}` : ""
            echoMode: TextInput.Password
            color: Theme.text
            placeholderTextColor: Theme.dim
            font.family: Theme.font
            font.pixelSize: 13
            background: Rectangle {
                radius: 6
                color: Theme.raised
            }
            onAccepted: {
                root.asking?.connectWithPsk(text);
                root.asking = null;
                text = "";
            }
            Keys.onEscapePressed: root.close()
        }

        Text {
            visible: root.failure !== ""
            Layout.fillWidth: true
            text: root.failure
            wrapMode: Text.Wrap
            color: Theme.accent
            font.family: Theme.font
            font.pixelSize: 11
        }
    }
}
