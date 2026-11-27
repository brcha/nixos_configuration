// CI skip test, do not merge
pragma Singleton

import QtQuick
import Quickshell

// Sweet-Mars, the Plasma colour scheme the bar uses
Singleton {
    readonly property color background: "#1c2124"
    readonly property color backgroundDark: "#161a1c"
    readonly property color raised: "#353945"
    readonly property color text: "#d3dae3"
    readonly property color dim: "#7c818c"
    readonly property color faint: "#4d525c"
    readonly property color accent: "#f67e7d"

    readonly property string font: "M+2 Nerd Font"
    readonly property int padding: 16

    // The bar: sections attached to the screen edge
    readonly property int barHeight: 40
    readonly property int barFontSize: 15
    readonly property int barIconSize: 22
    readonly property int barRadius: 12
    readonly property int barFillet: 12
    readonly property int barPadding: 6
    readonly property int barModulePadding: 10
}
