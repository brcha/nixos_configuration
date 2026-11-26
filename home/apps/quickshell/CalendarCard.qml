import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// Month calendar in the user's locale, with ISO week numbers
BarPopup {
    id: root

    readonly property int cell: 34
    property int month
    property int year
    // Quickshell runs for days; a plain new Date() in a binding would keep the start day
    readonly property date today: clock.date
    readonly property bool showingToday: month === today.getMonth() && year === today.getFullYear()

    function shift(months: int): void {
        const d = new Date(year, month + months, 1);
        month = d.getMonth();
        year = d.getFullYear();
    }

    function reset(): void {
        month = today.getMonth();
        year = today.getFullYear();
    }

    SystemClock {
        id: clock

        precision: SystemClock.Hours
    }

    Component.onCompleted: reset()
    onOpened: reset()

    ColumnLayout {
        spacing: 8

        // Wheel up shows the next month, like the bar's other scroll actions
        WheelHandler {
            onWheel: event => root.shift(event.angleDelta.y > 0 ? 1 : -1)
        }

        RowLayout {
            Layout.preferredWidth: 7 * root.cell

            ArrowButton {
                glyph: "󰅁"
                onClicked: root.shift(-1)
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.locale().standaloneMonthName(root.month, Locale.LongFormat) + " " + root.year
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                font.weight: Font.Medium
            }
            ArrowButton {
                glyph: "󰅂"
                onClicked: root.shift(1)
            }
        }

        DayOfWeekRow {
            Layout.preferredWidth: 7 * root.cell
            locale: Qt.locale()
            spacing: 0
            padding: 0
            delegate: Text {
                required property string shortName

                horizontalAlignment: Text.AlignHCenter
                text: shortName
                color: Theme.dim
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        RowLayout {
            spacing: 4

            MonthGrid {
                id: grid

                Layout.preferredWidth: 7 * root.cell
                month: root.month
                year: root.year
                locale: Qt.locale()
                spacing: 0
                padding: 0
                delegate: Item {
                    required property var model
                    // MonthGrid updates model.today only when the month changes
                    readonly property bool isToday: model.day === root.today.getDate() && model.month === root.today.getMonth() && model.year === root.today.getFullYear()

                    implicitWidth: root.cell
                    implicitHeight: 30

                    Rectangle {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: 13
                        color: Theme.accent
                        visible: isToday
                    }
                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        color: isToday ? Theme.backgroundDark : model.month === grid.month ? Theme.text : Theme.faint
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: isToday ? Font.Bold : Font.Normal
                    }
                }
            }

            WeekNumberColumn {
                month: root.month
                year: root.year
                locale: Qt.locale()
                spacing: 0
                padding: 0
                delegate: Text {
                    required property int weekNumber

                    height: 30
                    verticalAlignment: Text.AlignVCenter
                    text: weekNumber
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 11
                }
            }
        }

        // Back to the current month; shows today's date
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: todayLabel.implicitWidth + 20
            implicitHeight: todayLabel.implicitHeight + 8
            radius: height / 2
            color: todayArea.containsMouse ? Theme.raised : "transparent"
            border.color: Theme.raised
            visible: !root.showingToday

            Text {
                id: todayLabel

                anchors.centerIn: parent
                text: "󰃶 " + root.today.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                color: Theme.accent
                font.family: Theme.font
                font.pixelSize: 12
            }
            MouseArea {
                id: todayArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.reset()
            }
        }
    }

    component ArrowButton: Text {
        id: arrow

        required property string glyph
        signal clicked

        text: glyph
        color: arrowArea.containsMouse ? Theme.accent : Theme.dim
        font.family: Theme.font
        font.pixelSize: 18

        MouseArea {
            id: arrowArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: arrow.clicked()
        }
    }
}
