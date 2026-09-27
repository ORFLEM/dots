import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    // --- Стиль фона (из документации) ---
    opacity: 0.85
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: col.background3 }
        GradientStop { position: 0.05; color: col.background2 }
        GradientStop { position: 0.3; color: col.background1 }
        GradientStop { position: 0.7; color: col.background1 }
        GradientStop { position: 0.95; color: col.background2 }
        GradientStop { position: 1.0; color: col.background3 }
    }
    radius: mainRad

    // --- Сигналы для Main ---
    signal newResults(var results)
    signal applyRequested(string id, string path)

    // --- Состояние ---
    property string searchQuery: ""
    property var results: []
    property bool isLoading: false
    property var main: null

    // --- Поиск ---
    Timer {
        id: searchTimer
        interval: 500
        repeat: false
        onTriggered: {
            var q = root.searchQuery.trim()
            if (q.length > 0) {
                root.isLoading = true
                root.results = []
                searchProcess.command = [
                    "curl", "-s", "--max-time", "10",
                    "https://wallhaven.cc/api/v1/search?q=" + encodeURIComponent(q) +
                    "&categories=111&sorting=relevance&order=desc&ratios=16x9,16x10&page=1" +
                    "&purity=100"
                ]
                searchProcess.running = true
            } else {
                root.results = []
                root.isLoading = false
                newResults([])
            }
        }
    }

    Process {
        id: searchProcess
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { root.rawData += data }
        }
        property string rawData: ""
        onExited: {
            root.isLoading = false
            if (exitCode === 0 && rawData.length > 0) {
                try {
                    var parsed = JSON.parse(rawData)
                    var items = parsed.data || []
                    var formatted = items.map(function(w) {
                        return {
                            id: w.id,
                            thumb: w.thumbs.large,
                            path: w.path,
                            ratio: parseFloat(w.ratio)
                        }
                    })
                    root.results = formatted
                    newResults(formatted)
                } catch (e) {
                    console.error("Wallhaven parse error:", e)
                }
            } else {
                root.results = []
                newResults([])
            }
            rawData = ""
        }
    }

    // --- UI: Поле поиска ---
    TextField {
        id: searchField
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
        height: 40
        placeholderText: "Поиск на Wallhaven..."
        background: Rectangle {
            radius: 10
            color: col.background1
        }
        color: col.onSurface
        font.pixelSize: fontSize - 3
        font.family: fontFamily
        onTextChanged: {
            root.searchQuery = text
            searchTimer.restart()
        }
    }

    // --- Сетка результатов ---
    GridView {
        id: resultsGrid
        anchors { top: searchField.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
        cellWidth: (parent.width - 20) / 4
        cellHeight: cellWidth / 1.77
        model: root.results
        clip: true

        delegate: Item {
            id: delegateItem
            width: resultsGrid.cellWidth - 5
            height: resultsGrid.cellHeight - 5

            // Кнопка-обёртка (стиль из документации)
            Rectangle {
                anchors.fill: parent
                radius: mainRad - 3
                opacity: 0.65
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: col.backgroundAlt2 }
                    GradientStop { position: 0.275; color: col.backgroundAlt1 }
                    GradientStop { position: 0.725; color: col.backgroundAlt1 }
                    GradientStop { position: 1.0; color: col.backgroundAlt2 }
                }
            }

            // Ховер-эффект
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: mainRad - 5
                color: delegateItem.hovered ? col.accent : "transparent"
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            // Изображение
            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: modelData.thumb
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                radius: 4
            }

            property bool hovered: false
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: delegateItem.hovered = true
                onExited: delegateItem.hovered = false
                onClicked: {
                    if (root.main) {
                        root.main.downloadAndApply(modelData.id, modelData.path)
                    } else {
                        applyRequested(modelData.id, modelData.path)
                    }
                }
            }
        }

        // Индикатор загрузки
        Rectangle {
            anchors.centerIn: parent
            visible: root.isLoading
            width: 50; height: 50
            radius: 25
            color: col.primaryContainer
            Text {
                anchors.centerIn: parent
                text: "⏳"
                font.pixelSize: fontSize + 7
                font.family: fontFamily
                color: font
            }
        }

        // Сообщение "ничего не найдено"
        Text {
            anchors.centerIn: parent
            visible: !root.isLoading && root.results.length === 0 && root.searchQuery.length > 0
            text: "Ничего не найдено"
            color: col.font
            font.pixelSize: fontSize - 3
            font.family: fontFamily
        }
    }

    // Найти Main при загрузке
    Component.onCompleted: {
        var p = parent
        while (p) {
            if (p.hasOwnProperty("contentItem")) {
                root.main = p
                if (p.contentItem !== root) {
                    p.contentItem = root
                }
                break
            }
            p = p.parent
        }
    }
}
