import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The notification server (org.freedesktop.Notifications), the history and the
// popups waiting to show. quickshell.service runs only in the Hyprland session,
// and nothing installs a D-Bus activation file, so Plasma keeps its own server.
Scope {
    id: root

    // Popups are held back, except critical ones; the history still gets them
    property bool dnd: false
    // Newest first
    property var popups: []
    readonly property var history: Array.from(server.trackedNotifications.values).reverse()
    // Popup timers by notification id: here rather than in the popups, which
    // the bar rebuilds whenever the list changes
    property var timers: ({})

    function dropPopup(notification): void {
        popups = popups.filter(n => n !== notification);
        timers[notification.id]?.destroy();
        delete timers[notification.id];
    }

    // A hovered popup waits; its time starts again when the pointer leaves
    function pause(notification, paused): void {
        if (timers[notification.id])
            timers[notification.id].paused = paused;
    }

    function clearAll(): void {
        for (const n of popups.slice())
            dropPopup(n);
        for (const n of history)
            n.dismiss();
    }

    // 8 s, 5 s for low urgency; critical popups get none. An expired popup stays
    // in the history, except a transient one.
    Component {
        id: expiry

        Timer {
            required property Notification notification
            property bool paused: false

            interval: notification.urgency === NotificationUrgency.Low ? 5000 : 8000
            running: !paused
            onTriggered: {
                const n = notification;
                root.dropPopup(n);
                if (n.transient)
                    n.expire();
            }
        }
    }

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        // Plain text only: markup would let a sender's <img> fetch a URL
        bodyMarkupSupported: false

        onNotification: notification => {
            notification.tracked = true;
            notification.closed.connect(() => root.dropPopup(notification));
            if (root.dnd && notification.urgency !== NotificationUrgency.Critical)
                return;
            root.popups = [notification, ...root.popups];
            if (notification.urgency !== NotificationUrgency.Critical)
                root.timers[notification.id] = expiry.createObject(root, {
                    notification: notification
                });
        }
    }
}
