import QtQuick
// The Basic style: under the KDE platform theme Qt picks the Breeze style, which
// needs Kirigami and does not take a custom track and handle
import QtQuick.Controls.Basic

// A slider in the shell's colours
Slider {
    id: slider

    implicitHeight: 20

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 4
        radius: 2
        color: Theme.raised

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: slider.enabled ? Theme.accent : Theme.dim
        }
    }
    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 12
        height: 12
        radius: 6
        color: Theme.text
        visible: slider.enabled
    }
}
