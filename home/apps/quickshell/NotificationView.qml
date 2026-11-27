import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

// One notification: image or application icon, application name, summary,
// body and action buttons, with a close button. A click on it runs its
// default action; without one, it brings up the sending application.
Rectangle {
    id: root

    required property Notification notification
    readonly property bool hovered: hover.hovered
    readonly property string icon: iconSource()

    // A click on the notification or one of its actions
    signal activated
    // The close button
    signal closed

    // Its window, by desktop entry or by application name; otherwise starts it
    function raiseApp(): void {
        DesktopEntries.applications.values;
        const n = notification;
        const entry = DesktopEntries.byId(n.desktopEntry) ?? DesktopEntries.heuristicLookup(n.appName);
        const window = ToplevelManager.toplevels.values.find(w => {
            const id = DesktopEntries.heuristicLookup(w.appId)?.id ?? w.appId;
            return (entry && id === entry.id) || w.appId.toLowerCase() === n.appName.toLowerCase();
        });
        if (window)
            window.activate();
        else if (entry)
            Quickshell.execDetached(["uwsm", "app", "--", entry.id + ".desktop"]);
    }

    function iconSource(): string {
        const n = notification;
        if (n.image)
            return n.image;
        if (n.appIcon)
            return n.appIcon.startsWith("/") ? "file://" + n.appIcon : Quickshell.iconPath(n.appIcon, true);
        DesktopEntries.applications.values;
        const entry = DesktopEntries.byId(n.desktopEntry);
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    radius: 10
    color: hover.hovered ? Theme.raised : Qt.rgba(Theme.raised.r, Theme.raised.g, Theme.raised.b, 0.5)
    border.width: notification.urgency === NotificationUrgency.Critical ? 1 : 0
    border.color: Theme.accent

    HoverHandler {
        id: hover
    }

    TapHandler {
        // Invoking an action dismisses the notification unless it is resident; the
        // same here when it brings up the application. activated() removes this
        // view, so nothing of it runs after that.
        onTapped: {
            const n = root.notification;
            const action = n.actions.find(a => a.identifier === "default");
            if (!action)
                root.raiseApp();
            root.activated();
            if (action)
                action.invoke();
            else if (!n.resident)
                n.dismiss();
        }
    }

    RowLayout {
        id: content

        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        IconImage {
            Layout.alignment: Qt.AlignTop
            visible: root.icon !== ""
            implicitSize: 40
            source: root.icon
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.notification.appName
                    elide: Text.ElideRight
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 11
                }

                Text {
                    text: "󰅖"
                    color: closeHover.hovered ? Theme.accent : Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 14

                    HoverHandler {
                        id: closeHover
                    }

                    TapHandler {
                        onTapped: root.closed()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notification.summary
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notification.body
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 5
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 12
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: actionRepeater.count > 0
                spacing: 6

                Repeater {
                    id: actionRepeater

                    model: root.notification.actions.filter(a => a.identifier !== "default")

                    Rectangle {
                        id: action

                        required property NotificationAction modelData

                        implicitWidth: actionLabel.implicitWidth + 16
                        implicitHeight: actionLabel.implicitHeight + 8
                        radius: 6
                        color: actionHover.hovered ? Theme.accent : Theme.raised

                        Text {
                            id: actionLabel

                            anchors.centerIn: parent
                            text: action.modelData.text
                            color: actionHover.hovered ? Theme.backgroundDark : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 12
                        }

                        HoverHandler {
                            id: actionHover
                        }

                        TapHandler {
                            onTapped: {
                                action.modelData.invoke();
                                root.activated();
                            }
                        }
                    }
                }
            }
        }
    }
}
