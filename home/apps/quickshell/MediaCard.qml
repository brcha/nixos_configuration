// The playing media, the volumes and the audio devices (MediaControls), under
// the volume module
BarPopup {
    id: root

    // The applications playing sound, for the bar's volume drawer
    readonly property var apps: controls.apps

    onOpened: controls.reset()

    MediaControls {
        id: controls

        onDone: root.close()
    }
}
