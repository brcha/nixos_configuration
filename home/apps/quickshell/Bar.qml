import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

    component BarButton: Item {
        id: button

        property alias text: label.text
        property color textColor: Theme.text
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
            font.pixelSize: Theme.barFontSize
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

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    // Read again every minute, like Waybar did: the weather unit replaces the
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

            // On the sections, or on the edge strip while hidden
            HoverHandler {
                id: barHover
            }

            EdgeAutoHide {
                id: autoHide

                empty: (bar.monitor?.activeWorkspace?.toplevels.values.length ?? 0) === 0
                hovered: barHover.hovered
                keep: root.notificationClasses.includes("cc-open") || root.popups.some(card => card.open && card.screen === bar.screen)
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
