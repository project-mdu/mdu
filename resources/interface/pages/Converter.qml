import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform

Page {
    id: root
    objectName: "converterPage"
    padding: 0

    // Models
    ListModel { id: filesModel }
    ListModel { id: activeModel }
    ListModel { id: completedModel }

    Rectangle {
        anchors.fill: parent
        color: "#161616"  // Dark base color

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Left Sidebar - Files
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "#1e1e1e"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Sidebar Header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#2d2d2d"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: "\uE8A5"  // Fluent Icon for files
                                font.family: "Segoe Fluent Icons"
                                font.pixelSize: 14
                                color: "#a0a0a0"
                            }

                            Text {
                                text: "Media Files"
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            Item { Layout.fillWidth: true }

                            Button {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 28

                                contentItem: Text {
                                    text: "Add Files"
                                    color: "#ffffff"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#2c2c2c" : "#242424"
                                    border.color: "#404040"
                                    border.width: 1
                                    radius: 4
                                }

                                onClicked: fileDialog.open()
                            }
                        }
                    }

                    // Files List
                    ListView {
                        id: filesList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 8
                        clip: true
                        spacing: 4
                        model: filesModel

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 52
                            color: "transparent"
                            border.color: "#2c2c2c"
                            border.width: 1
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                Text {
                                    text: "\uE8A5"
                                    font.family: "Segoe Fluent Icons"
                                    font.pixelSize: 18
                                    color: "#a0a0a0"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: fileName || ""
                                        color: "#ffffff"
                                        elide: Text.ElideMiddle
                                        font.pixelSize: 12
                                        maximumLineCount: 1
                                        wrapMode: Text.NoWrap
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: filePath || ""
                                        color: "#808080"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        wrapMode: Text.NoWrap
                                    }
                                }

                                Button {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28

                                    contentItem: Text {
                                        text: "\uE74D"
                                        font.family: "Segoe Fluent Icons"
                                        color: "#a0a0a0"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 14
                                    }

                                    background: Rectangle {
                                        color: parent.hovered ? "#2c2c2c" : "transparent"
                                        border.color: "#2c2c2c"
                                        border.width: 1
                                        radius: 4
                                    }

                                    onClicked: filesModel.remove(index)
                                }
                            }
                        }

                        // Drag and Drop Area
                        Rectangle {
                            id: emptyStateDropArea
                            anchors.fill: parent
                            color: dropArea.containsDrag ? "#2c2c2c" : "transparent"
                            visible: filesModel.count === 0

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "\uE8A5"
                                    font.family: "Segoe Fluent Icons"
                                    font.pixelSize: 24
                                    color: dropArea.containsDrag ? "#0078D4" : "#404040"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: dropArea.containsDrag ? "Drop files to add" : "Drop media files here"
                                    color: dropArea.containsDrag ? "#0078D4" : "#404040"
                                    font.pixelSize: 12
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            DropArea {
                                id: dropArea
                                anchors.fill: parent
                                keys: ["text/uri-list"]

                                onDropped: (drop) => {
                                    if (drop.hasUrls) {
                                        for (let i = 0; i < drop.urls.length; i++) {
                                            let filePath = drop.urls[i].toString()
                                            filePath = filePath.replace(/^(file:\/{3})/, "")

                                            // Validate file extensions
                                            const validExtensions = ['.mp4', '.avi', '.mkv', '.mov', '.mp3', '.wav', '.flac']
                                            const fileExt = filePath.substring(filePath.lastIndexOf('.')).toLowerCase()

                                            if (validExtensions.includes(fileExt)) {
                                                let fileName = filePath.split('/').pop()

                                                filesModel.append({
                                                    fileName: fileName,
                                                    filePath: filePath
                                                })
                                            }
                                        }
                                        drop.acceptProposedAction()
                                    }
                                }

                                onEntered: (drag) => {
                                    drag.accepted = true
                                }
                            }
                        }
                    }

                    // Conversion Options
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        Layout.preferredHeight: 180
                        color: "#121212"
                        border.color: "#2c2c2c"
                        border.width: 1
                        radius: 4

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "Conversion Types"
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            ComboBox {
                                id: outputFormatCombo
                                Layout.fillWidth: true
                                model: ["MP4", "MKV", "AVI", "MOV", "MP3", "WAV", "FLAC"]

                                background: Rectangle {
                                    color: parent.down ? "#2c2c2c" : "#242424"
                                    border.color: "#404040"
                                    border.width: 1
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: parent.displayText
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                Layout.preferredHeight: 36
                                enabled: filesModel.count > 0

                                contentItem: Text {
                                    text: "Start Conversion"
                                    color: parent.enabled ? "#ffffff" : "#808080"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                }

                                background: Rectangle {
                                    color: parent.enabled
                                           ? (parent.hovered ? "#2c2c2c" : "#242424")
                                           : "#1e1e1e"
                                    border.color: parent.enabled ? "#404040" : "#2c2c2c"
                                    border.width: 1
                                    radius: 4
                                }

                                onClicked: startConversion()
                            }
                        }
                    }
                }
            }

            // Main Content Area - Progress
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#161616"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Progress Header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#2d2d2d"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: "Conversion Progress"
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                        }
                    }

                    // Active Tasks
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 8
                        clip: true
                        spacing: 4
                        model: activeModel

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 72
                            color: "transparent"
                            border.color: "#2c2c2c"
                            border.width: 1
                            radius: 4

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: fileName || ""
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: status || ""
                                        color: "#808080"
                                        font.pixelSize: 10
                                    }
                                }

                                ProgressBar {
                                    Layout.fillWidth: true
                                    value: progress || 0

                                    background: Rectangle {
                                        implicitHeight: 4
                                        color: "#2c2c2c"
                                        radius: 2
                                    }

                                    contentItem: Rectangle {
                                        width: parent.width * parent.parent.visualPosition
                                        height: 4
                                        radius: 2
                                        color: "#0078D4"
                                    }
                                }

                                // Conversion details
                                Flow {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Repeater {
                                        model: convertDetails || []

                                        Rectangle {
                                            width: typeText.width + 12
                                            height: 20
                                            radius: 10
                                            color: "#2c2c2c"

                                            Text {
                                                id: typeText
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: "#a0a0a0"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // File Dialog
    Platform.FileDialog {
        id: fileDialog
        title: "Choose media files"
        nameFilters: [
            "Media files (*.mp4 *.avi *.mkv *.mov *.mp3 *.wav *.flac *.m4a)"
        ]
        fileMode: Platform.FileDialog.OpenFiles

        onAccepted: {
            for (let i = 0; i < files.length; i++) {
                let filePath = files[i].toString()
                filePath = filePath.replace(/^(file:\/{3})/, "")
                let fileName = filePath.split('/').pop()

                filesModel.append({
                    fileName: fileName,
                    filePath: filePath
                })
            }
        }
    }

    function startConversion() {
        // Clear previous active tasks
        activeModel.clear()

        // Simulate conversion for each file
        for (let i = 0; i < filesModel.count; i++) {
            activeModel.append({
                fileName: filesModel.get(i).fileName,
                status: "Converting to " + outputFormatCombo.currentText,
                progress: 0,
                convertDetails: [
                    outputFormatCombo.currentText,
                    "Quality: High"
                ]
            })
        }

        // Start conversion simulation
        conversionTimer.start()
    }

    Timer {
        id: conversionTimer
        interval: 100
        repeat: true
        property int currentTask: 0

        onTriggered: {
            let task = activeModel.get(currentTask)
            task.progress += 0.05

            if (task.progress >= 1.0) {
                task.status = "Conversion Complete"
                currentTask++

                if (currentTask >= activeModel.count) {
                    stop()
                    currentTask = 0
                }
            }
        }
    }
}
