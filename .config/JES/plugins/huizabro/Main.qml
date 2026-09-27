import QtQuick
import Quickshell

Item {
    id: root

    property var requiredSettings: ({})

    // Что рендерить: "jwindow" (по умолчанию) | "aura" | "dump"
    readonly property string view:
        (requiredSettings && requiredSettings["view"] !== undefined)
            ? String(requiredSettings["view"])
            : "jwindow"

    implicitWidth:  view === "aura" ? 280
                 : view === "dump" ? 400
                 : 600
    implicitHeight: view === "aura" ? 220
                  : view === "dump" ? 220
                  : 300

    Component.onCompleted: {
        console.log("[testplugin] loaded, view =", view)
        console.log("[testplugin] requiredSettings =",
                    JSON.stringify(requiredSettings))
    }

    onRequiredSettingsChanged: {
        console.log("[testplugin] settings applied:",
                    JSON.stringify(requiredSettings))
    }

    Loader {
        anchors.fill: parent
        sourceComponent: {
            switch (root.view) {
                case "aura": return auraComp
                case "dump": return dumpComp
                default:     return jwindowComp
            }
        }
    }

    Component {
        id: jwindowComp
        JwindowTabTester {
            requiredSettings: root.requiredSettings
        }
    }

    Component {
        id: auraComp
        ColorAura {
            requiredSettings: root.requiredSettings
        }
    }

    // Режим "dump": просто показывает, что реально доехало из settings.json
    Component {
        id: dumpComp
        Rectangle {
            radius: mainRad - margins
            color: col.background2
            border.color: col.accent
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4

                Text {
                    text: "󰙨 testplugin — requiredSettings"
                    color: col.accent
                    font.family: fontFamily
                    font.pixelSize: fontSize + 2
                    font.bold: true
                }

                Repeater {
                    model: Object.keys(root.requiredSettings ?? {})

                    delegate: Text {
                        required property string modelData
                        text: "• " + modelData + " = "
                              + JSON.stringify(root.requiredSettings[modelData])
                        color: col.font
                        font.family: fontFamily
                        font.pixelSize: fontSize
                    }
                }

                Text {
                    visible: Object.keys(root.requiredSettings ?? {}).length === 0
                    text: "(requiredSettings is empty — проверь config.toml и manifest)"
                    color: col.fontDark
                    font.family: fontFamily
                    font.pixelSize: fontSize
                    opacity: 0.7
                }
            }
        }
    }
}
