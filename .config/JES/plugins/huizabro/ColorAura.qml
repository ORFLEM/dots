import QtQuick
import Quickshell

Item {
    id: root

    property var requiredSettings: ({})

    onRequiredSettingsChanged: {
        var keys = Object.keys(requiredSettings ?? {})
        console.log("[ColorAura] settings applied, keys:", keys.join(", "))
        console.log("[ColorAura] raw:", JSON.stringify(requiredSettings))
    }

    readonly property string headerText:
        (requiredSettings && requiredSettings["tileLabel"] !== undefined)
            ? String(requiredSettings["tileLabel"])
            : "color aura"

    readonly property var palette: [
        { name: "bg1",   value: col.background1    },
        { name: "bg2",   value: col.background2    },
        { name: "bg3",   value: col.background3    },
        { name: "alt1",  value: col.backgroundAlt1 },
        { name: "alt2",  value: col.backgroundAlt2 },
        { name: "font",  value: col.font           },
        { name: "fdark", value: col.fontDark       },
        { name: "acc",   value: col.accent         },
        { name: "acc2",  value: col.accent2        }
    ]

    property string lastCopied: ""

    Rectangle {
        anchors.fill: parent
        radius: mainRad - margins
        color: "transparent"
        border.color: col.accent
        border.width: 1
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 4

            // ── Шапка ──
            Row {
                width: parent.width
                height: 20
                spacing: 6

                Text {
                    text: "󰏘"
                    color: col.accent
                    font.pixelSize: fontSize + 2
                    font.bold: true
                    font.family: fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.headerText
                    color: col.font
                    font.pixelSize: fontSize
                    font.family: fontFamily
                    elide: Text.ElideRight
                    width: parent.width - 32
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // ── Сетка 3×3 ──
            Grid {
                width: parent.width
                height: parent.height - 20 - 18 - 4 - 4
                columns: 3
                rows: 3
                spacing: 3

                Repeater {
                    model: root.palette
                    delegate: Rectangle {
                        width:  (parent.width  - parent.spacing * 2) / 3
                        height: (parent.height - parent.spacing * 2) / 3
                        radius: mainRad - 5
                        color: modelData.value
                        border.color: col.accent
                        border.width: root.lastCopied === modelData.name ? 2 : 1

                        Behavior on border.width { NumberAnimation { duration: 150 } }

                        property bool hovered: false

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.color: col.font
                            border.width: 2
                            opacity: root.lastCopied === modelData.name ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: parent.hovered ? modelData.value : modelData.name
                            color: Qt.luminance(modelData.value) > 0.5 ? "#000000" : "#ffffff"
                            font.pixelSize: parent.hovered ? 9 : 10
                            font.bold: true
                            font.family: fontFamily
                            elide: Text.ElideRight
                            width: parent.width - 6
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: parent.hovered = true
                            onExited:  parent.hovered = false
                            onClicked: {
                                root.lastCopied = modelData.name
                                copyTimer.restart()
                                Quickshell.execDetached(["sh", "-c",
                                    "wl-copy " + modelData.value + " 2>/dev/null; " +
                                    "notify-send -a 'JES ColorAura' '" +
                                    modelData.name + "' '" + modelData.value + "'"])
                            }
                        }
                    }
                }
            }

            // ── Футер ──
            Row {
                width: parent.width
                height: 14
                spacing: 4

                Text {
                    text: "󰆏"
                    color: col.accent
                    font.pixelSize: 11
                    font.family: fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.lastCopied === ""
                          ? "click swatch to copy hex"
                          : ("copied: " + root.lastCopied)
                    color: col.font
                    font.pixelSize: 10
                    font.family: fontFamily
                    opacity: 0.8
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: parent.width - 20
                }
            }
        }
    }

    Timer {
        id: copyTimer
        interval: 1500
        repeat: false
        onTriggered: root.lastCopied = ""
    }

    Component.onCompleted: {
        console.log("[ColorAura] loaded")
        console.log("[ColorAura] accent =", col.accent, "font =", col.font)
    }
}
