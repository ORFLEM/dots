import QtQuick
import Quickshell

Rectangle {
    id: root

    property var requiredSettings: ({})

    readonly property string tileLabel:
        (requiredSettings && requiredSettings["tileLabel"] !== undefined)
            ? String(requiredSettings["tileLabel"])
            : "test tile"

    readonly property int tileSize:
        (requiredSettings && requiredSettings["tileSize"] !== undefined)
            ? Number(requiredSettings["tileSize"])
            : (fontSize + 6)

    readonly property string tileBg:
        (requiredSettings && requiredSettings["tileBg"] !== undefined)
            ? String(requiredSettings["tileBg"])
            : String(col.accent)

    implicitWidth: 600
    implicitHeight: 300
    radius: mainRad - margins
    color: col.background2

    onRequiredSettingsChanged: {
        console.log("[JwindowTab] settings applied:",
                    JSON.stringify(requiredSettings))
    }

    // Живой тайл, управляемый настройками из settings.json
    Rectangle {
        anchors.centerIn: parent
        width:  Math.max(120, tileSize * 6)
        height: Math.max(60,  tileSize * 2)
        radius: mainRad - margins
        color:  tileBg
        border.color: col.accent
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: tileLabel
            color: col.fontDark
            font.family: fontFamily
            font.pixelSize: tileSize
            font.bold: true
            elide: Text.ElideRight
            width: parent.width - 12
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Диагностика — видно, что доехало
    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 2

        Text {
            text: "tileLabel = " + root.tileLabel
            color: col.font
            font.family: fontFamily
            font.pixelSize: fontSize - 2
        }
        Text {
            text: "tileSize  = " + root.tileSize
            color: col.font
            font.family: fontFamily
            font.pixelSize: fontSize - 2
        }
        Text {
            text: "tileBg    = " + root.tileBg
            color: col.font
            font.family: fontFamily
            font.pixelSize: fontSize - 2
        }
    }
}
