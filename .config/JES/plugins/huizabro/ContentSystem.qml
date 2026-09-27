import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string cpuLoad: "12%"
    property string memUsed: "2.1/8.0 GB"
    property string uptime: "3h 22m"

    // ... остальной код (таймер, данные) без изменений ...

    // Фон (вертикальный градиент)
    Rectangle {
        anchors.fill: parent
        radius: mainRad - 3
        opacity: 0.8
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: col.background3 }
            GradientStop { position: 0.3; color: col.background2 }
            GradientStop { position: 0.7; color: col.background1 }
            GradientStop { position: 1.0; color: col.backgroundAlt1 }
        }
    }

    // Сетка с информацией (теперь 1 колонка, 3 строки, но занимает 1x2 ячейки)
    GridLayout {
        anchors.fill: parent
        anchors.margins: 5
        columns: 1
        rows: 3
        rowSpacing: 3

        // Три строки: CPU, Память, Аптайм
        Row {
            Layout.fillWidth: true
            spacing: 5
            Text { text: "CPU:"; color: "white"; font.pixelSize: parent.parent.height * 0.12 }
            Text { text: cpuLoad; color: "white"; font.pixelSize: parent.parent.height * 0.12 }
        }
        Row {
            Layout.fillWidth: true
            spacing: 5
            Text { text: "Память:"; color: "white"; font.pixelSize: parent.parent.height * 0.12 }
            Text { text: memUsed; color: "white"; font.pixelSize: parent.parent.height * 0.12 }
        }
        Row {
            Layout.fillWidth: true
            spacing: 5
            Text { text: "Аптайм:"; color: "white"; font.pixelSize: parent.parent.height * 0.12 }
            Text { text: uptime; color: "white"; font.pixelSize: parent.parent.height * 0.12 }
        }
    }

    // Кнопка ">" – как плавающая в правом нижнем углу, но с другим стилем
    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5
        width: parent.width * 0.2
        height: parent.height * 0.25

        Item {
            id: button
            anchors.fill: parent
            property bool hovered: false

            Rectangle {
                anchors.fill: parent
                radius: mainRad - 3
                opacity: 0.9
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: col.accent }
                    GradientStop { position: 1.0; color: col.backgroundAlt2 }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: mainRad - 5
                color: button.hovered ? Qt.lighter(col.accent, 1.2) : "transparent"
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                anchors.centerIn: parent
                text: "▶"
                color: "white"
                font.pixelSize: parent.height * 0.6
                font.family: fontFamily
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: button.hovered = true
                onExited: button.hovered = false
                onClicked: {
                    Quickshell.execDetached(["sh", "-c", "notify-send 'Системная информация: CPU " + cpuLoad + ", RAM " + memUsed + "'"])
                }
            }
        }
    }
}
