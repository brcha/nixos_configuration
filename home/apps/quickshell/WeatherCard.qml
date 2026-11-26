import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Current conditions and a three-day forecast, from the model the weather
// unit writes (home/apps/waybar-weather.jq)
BarPopup {
    id: root

    property var model: null

    // The file may not exist yet when Quickshell starts, so read it again on every open
    onOpened: file.reload()

    FileView {
        id: file

        path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/waybar-weather.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.model = JSON.parse(text());
            } catch (e) {
                root.model = null;
            }
        }
        onLoadFailed: root.model = null
    }

    ColumnLayout {
        spacing: 12

        Text {
            visible: !root.model
            text: "No weather data"
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 13
        }

        RowLayout {
            visible: !!root.model
            spacing: 14

            Text {
                text: root.model?.now.glyph ?? ""
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 52
            }
            ColumnLayout {
                spacing: 2

                Text {
                    text: (root.model?.now.temp ?? "") + "°"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 32
                    font.weight: Font.Medium
                }
                Text {
                    text: `${root.model?.now.text ?? ""}, feels like ${root.model?.now.feels ?? ""}°`
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 12
                }
            }
        }

        RowLayout {
            visible: !!root.model
            spacing: 16

            Detail {
                glyph: "󰖎"
                value: `${root.model?.now.humidity ?? ""} %`
            }
            Detail {
                glyph: "󰖝"
                value: `${root.model?.now.wind ?? ""} km/h ${root.model?.now.windDir ?? ""}`
            }
            Detail {
                glyph: "󰖜"
                value: root.model?.now.sunrise ?? ""
            }
            Detail {
                glyph: "󰖛"
                value: root.model?.now.sunset ?? ""
            }
        }

        RowLayout {
            visible: !!root.model
            spacing: 8

            Repeater {
                model: root.model?.days ?? []

                Rectangle {
                    id: tile

                    required property var modelData
                    required property int index
                    readonly property date day: {
                        const [y, m, d] = modelData.date.split("-").map(Number);
                        return new Date(y, m - 1, d);
                    }

                    Layout.fillWidth: true
                    implicitWidth: 92
                    implicitHeight: tileColumn.implicitHeight + 16
                    radius: 8
                    color: Theme.raised

                    ColumnLayout {
                        id: tileColumn

                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.locale().dayName(tile.day.getDay(), Locale.ShortFormat)
                            color: tile.index === 0 ? Theme.accent : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: tile.modelData.glyph
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 26
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            textFormat: Text.StyledText
                            text: `${tile.modelData.max}° <font color="${Theme.dim}">${tile.modelData.min}°</font>`
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: `󰖗 ${tile.modelData.rain} %`
                            color: Theme.dim
                            font.family: Theme.font
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }

        Text {
            visible: !!root.model
            text: `${root.model?.city ?? ""} · updated ${root.model?.updated ?? ""}`
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 11
        }
    }

    component Detail: Text {
        required property string glyph
        required property string value

        text: `${glyph} ${value}`
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 12
    }
}
