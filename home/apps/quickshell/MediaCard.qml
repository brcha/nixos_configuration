import QtQuick
// The Basic style: under the KDE platform theme Qt picks the Breeze style, which
// needs Kirigami and does not take a custom track and handle
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Widgets

// The playing media, output volume and device, volume per application, and
// microphone volume and device, from PipeWire and MPRIS
BarPopup {
    id: root

    // Nerd Font (Material Design) glyphs
    readonly property var glyph: ({
            music: "\u{F075A}",
            play: "\u{F040A}",
            pause: "\u{F03E4}",
            previous: "\u{F04AE}",
            next: "\u{F04AD}",
            shuffle: "\u{F049D}",
            repeat: "\u{F0456}",
            repeatOnce: "\u{F0458}",
            volume: "\u{F057E}",
            muted: "\u{F075F}",
            mic: "\u{F036C}",
            micOff: "\u{F036D}",
            settings: "\u{F04C3}"
        })

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: nodes.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property var sources: nodes.filter(n => n.audio && !n.isSink && !n.isStream)
    // isSink is true for playback streams too, so tell them from recording ones by media class
    readonly property var allStreams: nodes.filter(n => n.audio && n.isStream)
    readonly property var streams: allStreams.filter(n => n.properties["media.class"] === "Stream/Output/Audio")

    // One entry per application: {name, icon, nodes}
    readonly property var apps: {
        const groups = [];
        for (const node of streams) {
            const name = node.properties["application.name"] || node.description || node.name;
            let group = groups.find(g => g.name === name);
            if (!group) {
                group = {
                    name: name,
                    icon: node.properties["application.icon-name"] ?? "",
                    nodes: []
                };
                groups.push(group);
            }
            group.nodes.push(node);
        }
        return groups;
    }

    readonly property var players: Mpris.players.values
    // The player picked in the switcher; otherwise the playing one, else the first
    property string chosen: ""
    readonly property MprisPlayer player: players.find(p => p.dbusName === chosen) ?? players.find(p => p.isPlaying) ?? players[0] ?? null

    function time(seconds): string {
        const s = Math.floor(seconds);
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    onOpened: {
        outputPicker.expanded = false;
        inputPicker.expanded = false;
    }

    // Volume and mute are only valid on bound nodes; properties too, for the app names
    PwObjectTracker {
        objects: [root.sink, root.source, ...root.allStreams].filter(n => n)
    }

    // MPRIS does not push position updates
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && (root.player?.isPlaying ?? false)
        onTriggered: root.player.positionChanged()
    }

    ColumnLayout {
        width: 360
        spacing: 10

        // Now playing
        ColumnLayout {
            Layout.fillWidth: true
            visible: !!root.player
            spacing: 8

            Flow {
                Layout.fillWidth: true
                visible: root.players.length > 1
                spacing: 6

                Repeater {
                    model: root.players

                    Rectangle {
                        id: chip

                        required property MprisPlayer modelData
                        readonly property bool current: modelData === root.player

                        implicitWidth: chipLabel.implicitWidth + 16
                        implicitHeight: chipLabel.implicitHeight + 6
                        radius: height / 2
                        color: current ? Theme.accent : Theme.raised

                        Text {
                            id: chipLabel

                            anchors.centerIn: parent
                            text: chip.modelData.identity
                            color: chip.current ? Theme.backgroundDark : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.chosen = chip.modelData.dbusName
                        }
                    }
                }
            }

            // A click on the cover or title brings the player's window up
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                HoverHandler {
                    cursorShape: root.player?.canRaise ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
                TapHandler {
                    onTapped: {
                        if (!root.player?.canRaise)
                            return;
                        root.player.raise();
                        root.close();
                    }
                }

                Rectangle {
                    implicitWidth: 64
                    implicitHeight: 64
                    radius: 8
                    color: Theme.raised
                    clip: true

                    Image {
                        id: cover

                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        sourceSize: Qt.size(128, 128)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: cover.status !== Image.Ready
                        text: root.glyph.music
                        color: Theme.dim
                        font.family: Theme.font
                        font.pixelSize: 28
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.player?.trackTitle || root.player?.identity || ""
                        elide: Text.ElideRight
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: root.player?.trackArtist ?? ""
                        elide: Text.ElideRight
                        color: Theme.dim
                        font.family: Theme.font
                        font.pixelSize: 12
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: (root.player?.positionSupported ?? false) && (root.player?.lengthSupported ?? false)
                spacing: 0

                ThemedSlider {
                    id: seek

                    Layout.fillWidth: true
                    from: 0
                    to: Math.max(root.player?.length ?? 0, 1)
                    enabled: root.player?.canSeek ?? false

                    // Kept apart from value, which the binding below resets on release
                    property real seekTo: -1

                    onMoved: seekTo = value
                    onPressedChanged: {
                        if (pressed || seekTo < 0)
                            return;
                        root.player.position = seekTo;
                        seekTo = -1;
                    }

                    Binding {
                        target: seek
                        property: "value"
                        value: root.player?.position ?? 0
                        when: !seek.pressed
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    Small {
                        text: root.time(seek.value)
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Small {
                        text: root.time(root.player?.length ?? 0)
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                IconButton {
                    visible: root.player?.shuffleSupported ?? false
                    text: root.glyph.shuffle
                    active: root.player?.shuffle ?? false
                    onClicked: root.player.shuffle = !root.player.shuffle
                }
                IconButton {
                    text: root.glyph.previous
                    enabled: root.player?.canGoPrevious ?? false
                    onClicked: root.player.previous()
                }
                IconButton {
                    text: root.player?.isPlaying ? root.glyph.pause : root.glyph.play
                    font.pixelSize: 26
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player.togglePlaying()
                }
                IconButton {
                    text: root.glyph.next
                    enabled: root.player?.canGoNext ?? false
                    onClicked: root.player.next()
                }
                // None, then the whole playlist, then the current track
                IconButton {
                    visible: root.player?.loopSupported ?? false
                    text: root.player?.loopState === MprisLoopState.Track ? root.glyph.repeatOnce : root.glyph.repeat
                    active: (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                    onClicked: root.player.loopState = root.player.loopState === MprisLoopState.None ? MprisLoopState.Playlist : root.player.loopState === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
                }
            }

            Separator {}
        }

        Heading {
            text: "Output"
        }
        VolumeRow {
            nodes: root.sink ? [root.sink] : []
            glyph: root.glyph.volume
            mutedGlyph: root.glyph.muted
        }
        DevicePicker {
            id: outputPicker

            devices: root.sinks
            current: root.sink
            onPicked: node => Pipewire.preferredDefaultAudioSink = node
        }

        Separator {
            visible: root.apps.length > 0
        }
        Heading {
            visible: root.apps.length > 0
            text: "Applications"
        }
        Repeater {
            model: root.apps

            VolumeRow {
                required property var modelData

                nodes: modelData.nodes
                label: modelData.name
                icon: modelData.icon
                glyph: root.glyph.volume
                mutedGlyph: root.glyph.muted
            }
        }

        Separator {}
        Heading {
            text: "Input"
        }
        VolumeRow {
            nodes: root.source ? [root.source] : []
            glyph: root.glyph.mic
            mutedGlyph: root.glyph.micOff
        }
        DevicePicker {
            id: inputPicker

            devices: root.sources
            current: root.source
            onPicked: node => Pipewire.preferredDefaultAudioSource = node
        }

        Separator {}
        Text {
            Layout.alignment: Qt.AlignRight
            text: `${root.glyph.settings}  Sound settings`
            color: settingsArea.containsMouse ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: 12

            MouseArea {
                id: settingsArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["pavucontrol"]);
                    root.close();
                }
            }
        }
    }

    component Heading: Text {
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: 11
    }

    component Small: Text {
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: 11
    }

    component Separator: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.raised
    }

    component IconButton: Text {
        id: button

        property bool active: false
        signal clicked

        color: active ? Theme.accent : Theme.text
        opacity: enabled ? 1 : 0.4
        font.family: Theme.font
        font.pixelSize: 18

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    // Mute button, slider and percentage for one or more nodes; the first one is shown
    component VolumeRow: RowLayout {
        id: row

        required property var nodes
        required property string glyph
        required property string mutedGlyph
        property string label: ""
        property string icon: ""
        readonly property PwNode node: nodes[0] ?? null
        readonly property bool muted: node?.audio?.muted ?? false

        Layout.fillWidth: true
        spacing: 10

        IconButton {
            Layout.preferredWidth: 22
            text: row.muted ? row.mutedGlyph : row.glyph
            active: row.muted
            enabled: !!row.node
            onClicked: {
                const muted = !row.muted;
                for (const node of row.nodes)
                    node.audio.muted = muted;
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                visible: row.label !== ""
                spacing: 6

                IconImage {
                    readonly property string path: row.icon ? Quickshell.iconPath(row.icon, true) : ""

                    visible: path !== ""
                    source: path
                    implicitSize: 14
                }
                Text {
                    Layout.fillWidth: true
                    text: row.label
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 12
                }
            }
            ThemedSlider {
                id: volume

                Layout.fillWidth: true
                from: 0
                to: 1
                enabled: !!row.node
                onMoved: {
                    for (const node of row.nodes)
                        node.audio.volume = value;
                }

                // The wheel steps 1 %, like the bar's volume. Not the slider's own
                // wheel handling: Qt reports the mouse wheel here as a touchpad,
                // and only a WheelHandler can be told to take any device.
                WheelHandler {
                    acceptedDevices: PointerDevice.AllDevices
                    onWheel: event => {
                        const value = Math.max(0, Math.min(1, volume.value + (event.angleDelta.y > 0 ? 0.01 : -0.01)));
                        for (const node of row.nodes)
                            node.audio.volume = value;
                    }
                }

                Binding {
                    target: volume
                    property: "value"
                    value: row.node?.audio?.volume ?? 0
                    when: !volume.pressed
                }
            }
        }
        Text {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: `${Math.round((row.node?.audio?.volume ?? 0) * 100)} %`
            color: row.muted ? Theme.dim : Theme.text
            font.family: Theme.font
            font.pixelSize: 12
        }
    }

    // The current device; a click lists the others to switch to
    component DevicePicker: ColumnLayout {
        id: picker

        required property var devices
        required property PwNode current
        readonly property var others: devices.filter(d => d !== current)
        property bool expanded: false
        signal picked(PwNode node)

        function deviceName(node): string {
            // The description, as in pavucontrol: nicknames repeat ("HDMI 1" on two cards)
            return node?.description || node?.nickname || node?.name || "";
        }

        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: picker.deviceName(picker.current) || "No device"
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 12
            }
            Text {
                visible: picker.others.length > 0
                // Nerd Font chevron up and down
                text: picker.expanded ? "\u{F0143}" : "\u{F0140}"
                color: Theme.dim
                font.family: Theme.font
                font.pixelSize: 14
            }

            TapHandler {
                enabled: picker.others.length > 0
                onTapped: picker.expanded = !picker.expanded
            }
            HoverHandler {
                cursorShape: picker.others.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        Repeater {
            model: picker.expanded ? picker.others : []

            Text {
                id: option

                required property PwNode modelData

                Layout.fillWidth: true
                Layout.leftMargin: 12
                text: picker.deviceName(modelData)
                elide: Text.ElideRight
                color: optionArea.containsMouse ? Theme.accent : Theme.dim
                font.family: Theme.font
                font.pixelSize: 12

                MouseArea {
                    id: optionArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        picker.picked(option.modelData);
                        picker.expanded = false;
                    }
                }
            }
        }
    }
}
