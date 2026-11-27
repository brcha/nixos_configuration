import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets

// The top bar, one window per screen: three sections attached to the top edge.
// The cards belong to shell.qml; the bar asks for them through its signals.
Scope {
    id: root

    signal cardEnter(string name, var screen)
    signal cardLeave(string name)
    signal cardToggle(string name, var screen)

    // The cards (BarPopup); one open on a bar's screen keeps that bar shown
    property var popups: []

    // .bar of the model the weather unit writes: { text, tooltip }
    property var weather: null
    // State of swaync's notification centre, from swaync-client -swb
    property string notificationState: "none"
    property var notificationClasses: []
    property string notificationTooltip: ""

    // swaync is kept out of the profile (it would take notifications in Plasma)
    readonly property string swayncClient: Quickshell.env("SWAYNC_CLIENT") || "swaync-client"

    // Toggles drawer: the night light (wlsunset) and stay-awake units, started
    // and stopped by the unit-toggle script, which then calls refresh() over IPC
    readonly property string unitToggle: Quickshell.env("UNIT_TOGGLE")
    // { text, class (off, day, transition, night), tooltip } from the night light script
    property var nightLight: null
    property bool stayAwake: false
    // Short name of the main keyboard's active layout (us, rs)
    property string layout: ""

    // System drawer: from /proc, every 10 s
    property int cpuUsage: 0
    property var cpuLast: null
    property int cpus: 1
    property real load: 0
    property int memUsage: 0
    readonly property int loadPercent: Math.round(load * 100 / cpus)

    // Connectivity drawer
    readonly property var netDevice: Networking.devices.values.find(d => d.type !== DeviceType.None && d.connected) ?? null
    readonly property var wifiNetwork: netDevice?.type === DeviceType.Wifi ? netDevice.networks.values.find(n => n.connected) ?? null : null
    property string netAddress: ""
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property var btConnected: btAdapter?.devices.values.filter(d => d.connected) ?? []

    // Volume of the default output
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Privacy: streams that record the microphone or capture video (a shared
    // screen, or a camera through PipeWire) while a link feeds them
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream)
    readonly property var activeTargets: Pipewire.linkGroups.values.filter(g => g.state === PwLinkState.Active).map(g => g.target)
    readonly property var recording: streams.filter(n => n.properties["media.class"] === "Stream/Input/Audio" && activeTargets.includes(n))
    readonly property var sharing: streams.filter(n => n.properties["media.class"] === "Stream/Input/Video" && activeTargets.includes(n))

    // Failed units of the system and user managers, every 10 s
    property var failedUnits: []

    // Volume, mute and properties are only valid on bound nodes
    PwObjectTracker {
        objects: [root.sink, ...root.streams].filter(n => n)
    }

    Process {
        id: failedCheck

        command: ["sh", "-c", "systemctl --failed --no-legend --plain; systemctl --user --failed --no-legend --plain"]
        stdout: StdioCollector {
            onStreamFinished: root.failedUnits = text.split("\n").map(l => l.trim().split(/\s+/)[0]).filter(u => u)
        }
    }

    function refresh(): void {
        nightLightCheck.running = true;
        stayAwakeCheck.running = true;
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: nightLightCheck

        command: [Quickshell.env("NIGHTLIGHT_STATUS")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.nightLight = JSON.parse(text);
                } catch (e) {}
            }
        }
    }

    Process {
        id: stayAwakeCheck

        command: ["systemctl", "--user", "is-active", "--quiet", "stay-awake"]
        onExited: code => root.stayAwake = code === 0
    }

    Process {
        id: layoutCheck

        command: ["hyprctl", "devices", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const keyboard = JSON.parse(text).keyboards.find(k => k.main);
                    root.layout = keyboard.layout.split(",")[keyboard.active_layout_index] ?? "";
                } catch (e) {}
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name === "activelayout")
                layoutCheck.running = true;
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            loadFile.reload();
            addressCheck.running = true;
            failedCheck.running = true;
        }
    }

    // CPU use since the last reading, from the first (all CPUs) line of /proc/stat
    FileView {
        id: statFile

        path: "/proc/stat"
        onLoaded: {
            const lines = text().split("\n");
            const fields = lines[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = fields[3] + fields[4];
            const total = fields.reduce((sum, n) => sum + n, 0);
            if (root.cpuLast && total > root.cpuLast.total)
                root.cpuUsage = Math.round(100 * (1 - (idle - root.cpuLast.idle) / (total - root.cpuLast.total)));
            root.cpuLast = {
                idle: idle,
                total: total
            };
            root.cpus = Math.max(1, lines.filter(l => /^cpu\d/.test(l)).length);
        }
    }

    FileView {
        id: memFile

        path: "/proc/meminfo"
        onLoaded: {
            const value = name => Number(text().match(new RegExp("^" + name + ":\\s+(\\d+)", "m"))?.[1] ?? 0);
            const total = value("MemTotal");
            if (total > 0)
                root.memUsage = Math.round((total - value("MemAvailable")) * 100 / total);
        }
    }

    FileView {
        id: loadFile

        path: "/proc/loadavg"
        onLoaded: root.load = Number(text().split(" ")[0])
    }

    Process {
        id: addressCheck

        command: ["ip", "-j", "-4", "addr", "show", "dev", root.netDevice?.name ?? "lo"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const address = JSON.parse(text)[0]?.addr_info?.[0];
                    root.netAddress = address ? `${address.local}/${address.prefixlen}` : "";
                } catch (e) {
                    root.netAddress = "";
                }
            }
        }
    }

    onNetDeviceChanged: addressCheck.running = true

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    // Read again every minute: the weather unit replaces the
    // file, and it may not exist yet when Quickshell starts
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: weatherFile.reload()
    }

    FileView {
        id: weatherFile

        path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/waybar-weather.json"
        onLoaded: {
            try {
                root.weather = JSON.parse(text()).bar ?? null;
            } catch (e) {
                root.weather = null;
            }
        }
        onLoadFailed: root.weather = null
    }

    Process {
        id: swaync

        command: [root.swayncClient, "-swb"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    const state = JSON.parse(data);
                    root.notificationState = state.alt ?? "none";
                    root.notificationClasses = [].concat(state.class ?? []);
                    root.notificationTooltip = state.tooltip ?? "";
                } catch (e) {}
            }
        }
        // swaync may start after Quickshell, or restart
        onExited: swayncRetry.start()
    }

    Timer {
        id: swayncRetry

        interval: 2000
        onTriggered: swaync.running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
            // Tray menus open from this bar; while one is, the bar and the tray stay
            property int openMenus: 0
            // The focused window, if it is on this screen. From the Wayland toplevel
            // list: Hyprland's activeToplevel stays unset until the focus first changes.
            readonly property Toplevel activeWindow: {
                const window = ToplevelManager.activeToplevel;
                return window && window.screens.includes(modelData) && (monitor?.activeWorkspace?.toplevels.values.length ?? 0) > 0 ? window : null;
            }

            screen: modelData
            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: Theme.barHeight + Theme.barFillet
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            color: "transparent"

            WlrLayershell.namespace: "quickshell-bar"
            WlrLayershell.layer: WlrLayer.Top

            // Hidden sections move up out of the window
            readonly property real slide: -(1 - autoHide.progress) * height

            // Only the sections take input; the rest passes clicks to the windows.
            // Hidden, only a 2 px strip at the top edge does, to bring the bar back.
            mask: autoHide.shown ? sectionsMask : edgeMask

            // The sections' shown places: a Region tracking the item would follow
            // it up while it slides away, and not back down
            Region {
                id: sectionsMask

                Region {
                    x: left.x
                    width: left.width
                    height: left.height
                }
                Region {
                    x: centre.x
                    width: centre.width
                    height: centre.height
                }
                Region {
                    x: right.x
                    width: right.width
                    height: right.height
                }
            }

            Region {
                id: edgeMask

                width: bar.width
                height: 2
            }

            // On the sections, or on the edge strip while hidden.
            // shortcut: a drawer opening under a pointer resting exactly on the top
            // edge ends this hover without the pointer leaving; the next pointer
            // motion brings it back within the 300 ms hide delay, so the bar only
            // hides if the pointer stays perfectly still. Revisit after a Hyprland
            // or Quickshell update if it shows up in use.
            HoverHandler {
                id: barHover
            }

            EdgeAutoHide {
                id: autoHide

                empty: (bar.monitor?.activeWorkspace?.toplevels.values.length ?? 0) === 0
                hovered: barHover.hovered
                keep: bar.openMenus > 0 || root.notificationClasses.includes("cc-open") || root.popups.some(card => card.open && card.screen === bar.screen)
            }

            BarTooltip {
                id: tooltip

                anchor.window: bar
            }

            BarSection {
                id: left

                y: bar.slide
                atLeft: true

                Repeater {
                    model: Hyprland.workspaces.values.filter(w => w.id > 0 && w.monitor === bar.monitor).sort((a, b) => a.id - b.id)

                    Rectangle {
                        id: workspace

                        required property HyprlandWorkspace modelData
                        readonly property bool active: bar.monitor?.activeWorkspace === modelData

                        implicitWidth: workspaceLabel.implicitWidth + 16
                        implicitHeight: Theme.barHeight
                        color: modelData.urgent ? Theme.accent : active ? Theme.raised : "transparent"

                        Text {
                            id: workspaceLabel

                            anchors.centerIn: parent
                            text: workspace.modelData.name
                            color: workspace.modelData.urgent ? Theme.background : workspace.active ? Theme.accent : Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.barFontSize
                        }

                        Rectangle {
                            visible: workspace.active && !workspace.modelData.urgent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 2
                            color: Theme.accent
                        }

                        TapHandler {
                            onTapped: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspace.modelData.id} })`)
                        }
                    }
                }

                RowLayout {
                    visible: bar.activeWindow !== null
                    Layout.leftMargin: Theme.barModulePadding
                    Layout.rightMargin: Theme.barModulePadding
                    spacing: 8

                    IconImage {
                        implicitSize: Theme.barIconSize
                        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(bar.activeWindow?.appId ?? "")?.icon ?? "", "application-x-executable")
                    }

                    Text {
                        readonly property string title: bar.activeWindow?.title ?? ""

                        text: title.length > 60 ? title.slice(0, 59) + "…" : title
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.barFontSize
                    }
                }
            }

            BarSection {
                id: centre

                x: (bar.width - width) / 2
                y: bar.slide

                BarButton {
                    text: "󰃭 " + Qt.locale().toString(clock.date, "ddd dd MMM  HH:mm")
                    onHoveredChanged: hovered ? root.cardEnter("calendar", bar.screen) : root.cardLeave("calendar")
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            root.cardToggle("calendar", bar.screen);
                    }
                }

                BarButton {
                    visible: root.weather !== null
                    text: root.weather?.text ?? ""
                    onHoveredChanged: hovered ? root.cardEnter("weather", bar.screen) : root.cardLeave("weather")
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            root.cardToggle("weather", bar.screen);
                    }
                }
            }

            BarSection {
                id: right

                atRight: true
                x: bar.width - width
                y: bar.slide

                // Shown while any system or user unit has failed; a click lists them in Ghostty
                BarButton {
                    visible: root.failedUnits.length > 0
                    text: "✗ " + root.failedUnits.length
                    textColor: Theme.accent
                    tooltip: root.failedUnits.join("\n")
                    tooltipWindow: tooltip
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            Quickshell.execDetached(["ghostty", "--wait-after-command=true", "-e", Quickshell.env("FAILED_UNITS")]);
                    }
                }

                // Shown while an application records the microphone or captures video
                BarButton {
                    visible: root.recording.length + root.sharing.length > 0
                    text: [root.sharing.length > 0 ? "󰍹" : "", root.recording.length > 0 ? "󰍬" : ""].filter(s => s).join(" ")
                    textColor: Theme.accent
                    tooltip: [...root.sharing.map(n => "Screen or camera: " + (n.properties["application.name"] || n.name)), ...root.recording.map(n => "Microphone: " + (n.properties["application.name"] || n.name))].join("\n")
                    tooltipWindow: tooltip
                }

                // Night light, stay awake and the keyboard layout. The leader turns
                // accent while the night light is at night or changing, or stay awake is on.
                Drawer {
                    readonly property string nightPhase: ({
                            night: "night",
                            transition: "changing",
                            day: "daylight"
                        })[root.nightLight?.class] ?? "off"

                    leaderText: "󰔡"
                    leaderColor: nightPhase === "night" || nightPhase === "changing" || root.stayAwake ? Theme.accent : Theme.text
                    leaderTooltip: `Night light: ${nightPhase}\nStay awake: ${root.stayAwake ? "on" : "off"}`
                    tooltipWindow: tooltip

                    BarButton {
                        text: root.nightLight?.text ?? "󰖙"
                        textColor: root.nightLight?.class === "off" ? Theme.dim : root.nightLight?.class === "night" ? Theme.accent : Theme.text
                        tooltip: root.nightLight?.tooltip ?? ""
                        tooltipWindow: tooltip
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                Quickshell.execDetached([root.unitToggle, "wlsunset"]);
                        }
                    }

                    // No lock and no screen-off while on
                    BarButton {
                        text: root.stayAwake ? "󰅶" : "󰾪"
                        textColor: root.stayAwake ? Theme.accent : Theme.text
                        tooltip: root.stayAwake ? "Staying awake: no lock, no screen-off" : "Idle timers active (lock after 10 min)"
                        tooltipWindow: tooltip
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                Quickshell.execDetached([root.unitToggle, "stay-awake"]);
                        }
                    }

                    BarButton {
                        text: "󰌌 " + root.layout
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"]);
                        }
                    }
                }

                // Hover shows the media and volume card, a click holds it; the wheel
                // changes the volume, a middle click mutes (with the on-screen
                // indicator), a right click opens pavucontrol
                BarButton {
                    text: root.muted ? "󰝟" : ["󰕿", "󰖀", "󰕾"][Math.min(2, Math.floor(root.volume * 3))] + " " + Math.round(root.volume * 100) + "%"
                    textColor: root.muted ? Theme.dim : Theme.text
                    onHoveredChanged: hovered ? root.cardEnter("media", bar.screen) : root.cardLeave("media")
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            root.cardToggle("media", bar.screen);
                        else if (pressed === Qt.MiddleButton)
                            Quickshell.execDetached(["swayosd-client", "--output-volume", "mute-toggle"]);
                        else if (pressed === Qt.RightButton)
                            Quickshell.execDetached(["pavucontrol"]);
                    }

                    // 1 % per step up to 100 %; a volume set above 100 %
                    // elsewhere is left alone by scrolling up, not cut back
                    WheelHandler {
                        // Qt reports the mouse wheel here as a touchpad, which the
                        // default device filter drops
                        acceptedDevices: PointerDevice.AllDevices
                        onWheel: event => {
                            const step = event.angleDelta.y > 0 ? 0.01 : -0.01;
                            if (!root.sink?.audio || (step > 0 && root.volume >= 1))
                                return;
                            root.sink.audio.volume = Math.max(0, Math.min(1, root.volume + step));
                        }
                    }
                }

                // Network and Bluetooth. The leader dims without a network connection
                // and turns accent while a Bluetooth device is connected.
                Drawer {
                    leaderText: "󰛳"
                    leaderColor: !root.netDevice ? Theme.dim : root.btConnected.length > 0 ? Theme.accent : Theme.text
                    leaderTooltip: `Network: ${root.netDevice ? "connected" : "disconnected"}\nBluetooth: ${root.btConnected.length > 0 ? root.btConnected.map(d => d.name).join(", ") : "nothing connected"}`
                    tooltipWindow: tooltip

                    BarButton {
                        text: !root.netDevice ? "󰖪" : root.wifiNetwork ? "󰖩 " + root.wifiNetwork.name : "󰈀"
                        textColor: root.netDevice ? Theme.text : Theme.dim
                        tooltip: !root.netDevice ? "offline" : root.wifiNetwork ? `${root.wifiNetwork.name} (${Math.round(root.wifiNetwork.signalStrength * 100)}%)  ${root.netAddress}` : `${root.netDevice.name}: ${root.netAddress}`
                        tooltipWindow: tooltip
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                Quickshell.execDetached(["kcmshell6", "kcm_networkmanagement"]);
                        }
                    }

                    BarButton {
                        readonly property bool on: root.btAdapter?.enabled ?? false

                        text: !on ? "󰂲" : root.btConnected.length > 0 ? "󰂱 " + root.btConnected.length : "󰂯"
                        textColor: on ? Theme.text : Theme.dim
                        tooltip: root.btConnected.length > 0 ? root.btConnected.map(d => d.name).join("\n") : `${root.btAdapter?.name ?? "Bluetooth"}  ${on ? "on" : "off"}`
                        tooltipWindow: tooltip
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                Quickshell.execDetached(["kcmshell6", "kcm_bluetooth"]);
                        }
                    }
                }

                // CPU and memory. The leader turns accent at 80 % load per CPU or
                // memory in use; a click on cpu or memory pins the drawer too.
                Drawer {
                    id: systemDrawer

                    leaderText: "󰊚"
                    leaderColor: root.loadPercent >= 80 || root.memUsage >= 80 ? Theme.accent : Theme.text
                    leaderTooltip: `Load: ${root.load} (${root.loadPercent} % of ${root.cpus} CPUs)\nMemory: ${root.memUsage} % in use`
                    tooltipWindow: tooltip

                    BarButton {
                        text: `󰘚 ${root.cpuUsage}%`
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                systemDrawer.togglePin();
                        }
                    }

                    BarButton {
                        text: `󰍛 ${root.memUsage}%`
                        onClicked: pressed => {
                            if (pressed === Qt.LeftButton)
                                systemDrawer.togglePin();
                        }
                    }
                }

                // Click for the notification panel, right-click for do-not-disturb
                BarButton {
                    readonly property bool quiet: root.notificationState.includes("dnd") || root.notificationState.includes("inhibited")

                    text: root.notificationState === "notification" ? "󱅫" : quiet ? "󰂛" : "󰂚"
                    textColor: root.notificationState === "notification" ? Theme.accent : quiet ? Theme.dim : Theme.text
                    underline: root.notificationClasses.includes("cc-open")
                    tooltip: root.notificationTooltip
                    tooltipWindow: tooltip
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            Quickshell.execDetached([root.swayncClient, "-t", "-sw"]);
                        else if (pressed === Qt.RightButton)
                            Quickshell.execDetached([root.swayncClient, "-d", "-sw"]);
                    }
                }

                // Every tray item, passive ones too (KDE Connect while no device is
                // reachable). kded6 keeps the item list, so it outlives Quickshell
                // restarts; Quickshell only reads it.
                Drawer {
                    leaderText: "󱊔"
                    leaderTooltip: "Tray"
                    tooltipWindow: tooltip
                    keepOpen: bar.openMenus > 0

                    Repeater {
                        model: SystemTray.items.values

                        Item {
                            id: trayItem

                            required property SystemTrayItem modelData

                            implicitWidth: Theme.barIconSize + 10
                            implicitHeight: Theme.barHeight

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: Theme.barIconSize - 2
                                source: trayItem.modelData.icon
                            }

                            HoverHandler {
                                onHoveredChanged: {
                                    if (hovered)
                                        tooltip.show(trayItem, trayItem.modelData.tooltipTitle || trayItem.modelData.title);
                                    else
                                        tooltip.hide(trayItem);
                                }
                            }

                            // Left click activates (or opens the menu of a menu-only
                            // item), middle click is the secondary action, right click
                            // opens the menu
                            TapHandler {
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                onTapped: (point, pressed) => {
                                    const item = trayItem.modelData;
                                    if (pressed === Qt.LeftButton && !item.onlyMenu) {
                                        item.activate();
                                    } else if (pressed === Qt.MiddleButton) {
                                        item.secondaryActivate();
                                    } else if (item.hasMenu) {
                                        const pos = trayItem.mapToItem(null, 0, 0);
                                        menu.anchor.rect.x = pos.x;
                                        menu.anchor.rect.y = pos.y;
                                        menu.anchor.rect.width = trayItem.width;
                                        menu.anchor.rect.height = trayItem.height;
                                        menu.open();
                                    }
                                }
                            }

                            WheelHandler {
                                // The mouse wheel arrives as a touchpad
                                acceptedDevices: PointerDevice.AllDevices
                                onWheel: event => trayItem.modelData.scroll(event.angleDelta.y, false)
                            }

                            // Anchored to the bar window by rectangle, like the tooltips
                            QsMenuAnchor {
                                id: menu

                                menu: trayItem.modelData.menu
                                anchor.window: bar
                                anchor.edges: Edges.Bottom
                                anchor.gravity: Edges.Bottom
                                onVisibleChanged: bar.openMenus += visible ? 1 : -1
                            }

                            // An item that goes away with its menu open must not
                            // keep the bar shown for good
                            Component.onDestruction: if (menu.visible)
                                bar.openMenus -= 1
                        }
                    }
                }

                // The power menu (wlogout), the same as Super+M
                BarButton {
                    text: "󰐥"
                    tooltip: "Power menu"
                    tooltipWindow: tooltip
                    onClicked: pressed => {
                        if (pressed === Qt.LeftButton)
                            Quickshell.execDetached(["power-menu"]);
                    }
                }
            }
        }
    }
}
