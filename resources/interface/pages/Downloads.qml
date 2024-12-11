// interface/pages/Downloads.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Window
import Qt.labs.platform
import "../models" as Modelx
import "../components" as Components

Page {
    id: root

    property bool isLoading: false
    property var downloadData: []
    // property QtObject ytdlpHelper: YtDlpHelper {}

    Component.onCompleted: {
        loadDownloadHistory()
    }
    Components.DownloadModal {
        id: downloadModal

        onAccepted: function(config) {  // Add the config parameter here
            // Create options list based on download config
            let options = []

            // Set video quality
            if (!config.audioOnly) {  // Use config instead of downloadConfig
                if (config.resolution !== "Auto") {
                    options.push("-f")
                    options.push(`bestvideo[height<=${config.resolution.replace("p", "")}]+bestaudio[ext=m4a]/best`)
                }

                // Add framerate option if enabled
                if (config.framerate !== "auto") {
                    options.push("--max-fps")
                    options.push(config.framerate.replace("fps", ""))
                }
            } else {
                // Audio only download
                options.push("-x")
                options.push("--audio-format")
                options.push(config.audioFormat.toLowerCase())
            }

            // Add thumbnail option
            if (config.withThumbnails) {
                options.push("--write-thumbnail")
            }

            // Add playlist option
            if (config.asPlaylist) {
                options.push("--yes-playlist")
            } else {
                options.push("--no-playlist")
            }

            // Add encoding options if enabled
            if (config.encoding) {
                options.push("--recode-video")
                options.push(config.encoding.codec.toLowerCase())
                if (config.encoding.bitrate !== "Auto") {
                    options.push("--video-quality")
                    options.push(config.encoding.bitrate.replace("k", ""))
                }
            }

            // Get download directory
            let downloadDir = downloadManager.getDefaultDownloadsPath()
            let outputTemplate = downloadDir + "/%(title)s.%(ext)s"

            console.log("Download directory:", downloadDir)
            console.log("Output template:", outputTemplate)

            // Start download using YtDlpHelper
            ytdlpHelper.startDownload(config.url, outputTemplate, options)
            dialogManager.showConfirmation("Download Started", "Download has been added to the queue")
        }
    }
    Connections {
        target: ytdlpHelper

        function onProgressUpdated(progress) {
            // Update progress in downloads list
            let found = false
            for (let i = 0; i < downloadsList.model.count; i++) {
                if (downloadsList.model.get(i).fileName === progress.filename) {
                    downloadsList.model.setProperty(i, "progress", progress.percentage)
                    downloadsList.model.setProperty(i, "status", progress.status)
                    found = true
                    break
                }
            }

            if (!found && progress.filename) {
                downloadsList.model.append({
                    fileName: progress.filename,
                    fileType: progress.state === DownloadState.Downloading ? "Downloading" : "Processing",
                    progress: progress.percentage,
                    status: progress.status,
                    filePath: ""
                })
            }
        }

        function onDownloadFinished(success, filename) {
            if (success) {
                loadDownloadHistory()
            }
        }

        function onDownloadError(error) {
            dialogManager.showError("Download Error", error)
        }
    }

    Connections {
        target: downloadManager

        function onDownloadHistoryLoaded(data) {
            downloadsList.model.clear()
            downloadData = data

            for (var i = 0; i < data.length; i++) {
                downloadsList.model.append({
                    fileName: data[i].filename,
                    fileType: data[i].file_type,
                    filePath: data[i].path,
                    progress: 100,
                    status: "Completed"
                })
            }

            updateTypesCounts()
            isLoading = false
        }

        function onLoadingError(error) {
            isLoading = false
            dialogManager.showError("Loading Error", "Error loading downloads: " + error)
        }
    }

    function loadDownloadHistory() {
        isLoading = true
        downloadManager.loadDownloadHistoryAsync()
    }

    function updateTypesCounts() {
        let counts = {
            "all": downloadData.length,
            "videos": 0,
            "audio": 0
        }

        downloadData.forEach(function(item) {
            let fileType = item.file_type.toLowerCase()
            if (fileType.includes("video")) {
                counts.videos++
            } else if (fileType.includes("audio")) {
                counts.audio++
            }
        })

        typesTree.model.updateCounts(counts)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#2d2d2d"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 8

                Label {
                    text: "Downloads"
                    font.pixelSize: 16
                    font.weight: 600
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Add Task Button
                Button {
                    id: addButton
                    text: "\uE710"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 14
                    flat: true
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                        radius: 4
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "Add Task"

                    onClicked: downloadModal.open()
                }

                // Stop All Button
                Button {
                    id: stopButton
                    text: "\uE71A"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 14
                    flat: true
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    enabled: downloadsList.count > 0

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#ffffff"
                        opacity: parent.enabled ? 1.0 : 0.5
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                        radius: 4
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "Stop All"

                    onClicked: ytdlpHelper.cancelDownload()
                }

                // Clear All Button
                Button {
                    id: clearButton
                    text: "\uE74D"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 14
                    flat: true
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    enabled: downloadsList.count > 0

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#ffffff"
                        opacity: parent.enabled ? 1.0 : 0.5
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                        radius: 4
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "Clear All"

                    onClicked: {
                        dialogManager.showClearConfirmation(function() {
                            downloadsList.model.clear()
                            downloadData = []
                            updateTypesCounts()
                        })
                    }
                }
            }
        }

        // Content
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            handle: Rectangle {
                implicitWidth: 2
                color: "#404040"
            }

            // Left panel - Types Tree
            Rectangle {
                id: typesPanel
                SplitView.preferredWidth: 250
                SplitView.minimumWidth: 200
                color: "#252525"

                ListView {
                    id: typesTree
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    model: Modelx.TypesModel {}

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 32

                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(255, 255, 255, 0.05) : "transparent"
                            radius: 4
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: icon
                                font.family: "Segoe Fluent Icons"
                                font.pixelSize: 16
                                color: "#ffffff"
                            }

                            Text {
                                text: name
                                font.pixelSize: 13
                                color: "#ffffff"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: count
                                font.pixelSize: 12
                                color: "#808080"
                            }
                        }

                        onClicked: {
                            // Implement filter logic here
                            console.log("Selected type:", name)
                        }
                    }
                }
            }

            // Right panel - Downloads List
            Rectangle {
                id: downloadsPanel
                SplitView.fillWidth: true
                color: "#1e1e1e"

                // Loading Overlay
                Rectangle {
                    anchors.fill: parent
                    color: "#1e1e1e"
                    visible: isLoading

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: isLoading
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 48
                        text: "Loading downloads..."
                        color: "#ffffff"
                        font.pixelSize: 14
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    visible: !isLoading

                    // Search bar
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search downloads"
                        height: 32

                        background: Rectangle {
                            color: "#333333"
                            radius: 4
                        }

                        color: "#ffffff"
                        selectByMouse: true

                        onTextChanged: {
                            // Implement search logic here
                            console.log("Search text:", text)
                        }
                    }

                    // Downloads list
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            id: downloadsList
                            anchors.fill: parent
                            spacing: 8
                            model: ListModel {}

                            delegate: Components.DownloadItem {
                                width: downloadsList.width
                                fileName: model.fileName
                                // fileType: model.fileType
                                progress: model.progress
                                status: model.status

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = Qt.rgba(255, 255, 255, 0.08)
                                    onExited: parent.color = Qt.rgba(255, 255, 255, 0.05)
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "No downloads yet"
                                color: "#808080"
                                font.pixelSize: 14
                                visible: downloadsList.count === 0
                            }
                        }
                    }
                }
            }
        }
    }
}
