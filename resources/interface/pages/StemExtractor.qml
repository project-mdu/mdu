// pages/StemExtractor.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Qt.labs.platform as Platform

Page {
    id: root
    objectName: "stemExtractorPage"
    padding: 0

    // Property for UVRHelper
    property var uviHelper: null

    // Models
    ListModel { id: filesModel }
    ListModel { id: activeModel }
    ListModel { id: completedModel }

    // Helper functions
    function getArchTypeFromString(modelType) {
        switch(modelType) {
            case "MDX-Net": return UVRHelper.ArchType.MDX
            case "VR-Architecture": return UVRHelper.ArchType.VR
            case "Demucs": return UVRHelper.ArchType.DEMUCS
            case "MDX-Net Chunks": return UVRHelper.ArchType.MDX_C
            default: return UVRHelper.ArchType.MDX
        }
    }

    function getOutputFormatFromString(format) {
        switch(format) {
            case "WAV": return UVRHelper.OutputFormat.WAV
            case "MP3": return UVRHelper.OutputFormat.MP3
            case "FLAC": return UVRHelper.OutputFormat.FLAC
            default: return UVRHelper.OutputFormat.WAV
        }
    }

    function startExtraction() {
        if (!uviHelper) {
            console.error("UVRHelper not initialized")
            return
        }

        // Get selected extraction types
        let selectedTypes = []
        for (let i = 0; i < extractionTypesRepeater.model.count; i++) {
            if (extractionTypesRepeater.model.get(i).checked) {
                selectedTypes.push(extractionTypesRepeater.model.get(i).type)
            }
        }

        // Process each file
        for (let i = 0; i < filesModel.count; i++) {
            let file = filesModel.get(i)
            processFile(file, selectedTypes)
        }
    }

    function processFile(file, selectedTypes) {
        // Add to active model
        let activeIndex = activeModel.count
        activeModel.append({
            fileName: file.fileName,
            filePath: file.filePath,
            progress: 0,
            status: "Starting...",
            extractTypes: selectedTypes
        })

        selectedTypes.forEach(type => {
            let deviceType = deviceSelector.currentValue === "GPU" ?
                            UVRHelper.DeviceType.CUDA :
                            UVRHelper.DeviceType.CPU

            uviHelper.processAudio(
                file.filePath,
                modelPathField.text,
                outputPathField.text,
                getArchTypeFromString(modelTypeSelector.currentText),
                type,
                deviceType,
                getOutputFormatFromString(formatSelector.currentText),
                bitrateSelector.value
            )
        })
    }

    Rectangle {
        anchors.fill: parent
        color: "#161616"

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
                                text: "\uE8A5"
                                font.family: "Segoe Fluent Icons"
                                font.pixelSize: 14
                                color: "#a0a0a0"
                            }

                            Text {
                                text: "Files"
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

                        // Empty state with Drag and Drop
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
                                    text: dropArea.containsDrag ? "Drop files to add" : "Drop audio files here"
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
                                            const validExtensions = ['.mp3', '.wav', '.flac', '.m4a']
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

                    // Extraction Controls
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
                                text: "Extraction Types"
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            Flow {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    id: extractionTypesRepeater
                                    model: ListModel {
                                        ListElement { name: "Vocals"; type: "vocal"; checked: true }
                                        ListElement { name: "Drums"; type: "drum"; checked: true }
                                        ListElement { name: "Bass"; type: "bass"; checked: true }
                                        ListElement { name: "Guitar"; type: "guitar"; checked: true }
                                        ListElement { name: "Other"; type: "instrument"; checked: false }
                                    }

                                    CheckBox {
                                        text: model.name
                                        checked: model.checked

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            leftPadding: parent.indicator.width + parent.spacing
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        indicator: Rectangle {
                                            width: 18
                                            height: 18
                                            radius: 4
                                            color: "transparent"
                                            y: 6
                                            border.color: parent.checked ? "#0078D4" : "#404040"
                                            border.width: 1

                                            Rectangle {
                                                width: 10
                                                height: 10
                                                radius: 2
                                                anchors.centerIn: parent
                                                color: "#0078D4"
                                                visible: parent.parent.checked
                                            }
                                        }

                                        onCheckedChanged: {
                                            model.checked = checked
                                        }
                                    }
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                Layout.preferredHeight: 36
                                enabled: filesModel.count > 0

                                contentItem: Text {
                                    text: "Start Extraction"
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

                                onClicked: startExtraction()
                            }
                        }
                    }
                }
            }

            // Main Content Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#161616"

                SplitView {
                    anchors.fill: parent
                    orientation: Qt.Vertical

                    handle: Rectangle {
                        implicitWidth: 2
                        implicitHeight: 2
                        color: "#1a1a1a"

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#1a1a1a" }
                                GradientStop { position: 0.5; color: "#2d2d2d" }
                                GradientStop { position: 1.0; color: "#1a1a1a" }
                            }
                        }

                        // Optional: Hover effect
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            visible: parent.hovered
                            color: "#404040"
                        }
                    }

                    // Upper section - Progress
                    Rectangle {
                        SplitView.preferredHeight: parent.height * 0.7
                        SplitView.minimumHeight: 200
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
                                    spacing: 0

                                    Text {
                                        text: "Progress"
                                        color: "#a0a0a0"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        Text {
                                            text: "Process Device"
                                            color: "#a0a0a0"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }
                                        ComboBox {
                                            id: deviceSelector
                                            Layout.preferredWidth: 120
                                            Layout.preferredHeight: 32
                                            model: ["CPU", "GPU"]
                                            currentIndex: 0

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
                                                width: parent.width * parent.visualPosition
                                                height: 4
                                                radius: 2
                                                color: "#0078D4"
                                            }
                                        }

                                        Flow {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Repeater {
                                                model: extractTypes || []

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

                    // Lower section - Settings
                    Rectangle {
                        id: settingsSection
                        SplitView.preferredHeight: parent.height * 0.3
                        SplitView.minimumHeight: 300
                        color: "#161616"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "Settings"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                ColumnLayout {
                                    width: settingsSection.width - 24
                                    spacing: 16

                                    // Model Settings
                                    GroupBox {
                                        Layout.fillWidth: true
                                        title: "Model Settings"
                                        padding: 12

                                        background: Rectangle {
                                            color: "#1e1e1e"
                                            border.color: "#2c2c2c"
                                            border.width: 1
                                            radius: 4
                                        }

                                        label: Text {
                                            text: parent.title
                                            color: "#a0a0a0"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            y:8
                                            leftPadding: 8
                                        }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8

                                                Text {
                                                    text: "Model Path:"
                                                    color: "#ffffff"
                                                    font.pixelSize: 12
                                                }

                                                TextField {
                                                    id: modelPathField
                                                    Layout.fillWidth: true
                                                    text: uvrHelper.getModelPath()
                                                    color: "#ffffff"
                                                    font.pixelSize: 12
                                                    background: Rectangle {
                                                        color: "#242424"
                                                        border.color: "#404040"
                                                        border.width: 1
                                                        radius: 4
                                                    }
                                                }

                                                Button {
                                                    text: "Browse"
                                                    onClicked: modelPathDialog.open()

                                                    contentItem: Text {
                                                        text: parent.text
                                                        color: "#ffffff"
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    background: Rectangle {
                                                        color: parent.hovered ? "#2c2c2c" : "#242424"
                                                        border.color: "#404040"
                                                        border.width: 1
                                                        radius: 4
                                                    }
                                                }
                                            }

                                            ComboBox {
                                                id: modelTypeSelector
                                                Layout.fillWidth: true
                                                model: ["MDX-Net", "VR-Architecture", "Demucs", "MDX-Net Chunks"]
                                                currentIndex: 0

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
                                        }
                                    }

                                    // Output Settings
                                    GroupBox {
                                        Layout.fillWidth: true
                                        title: "Output Settings"
                                        padding: 12

                                        background: Rectangle {
                                            color: "#1e1e1e"
                                            border.color: "#2c2c2c"
                                            border.width: 1
                                            radius: 4
                                        }

                                        label: Text {
                                            text: parent.title
                                            color: "#a0a0a0"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            y:8
                                            leftPadding: 8
                                        }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8

                                                Text {
                                                    text: "Output Path:"
                                                    color: "#ffffff"
                                                    font.pixelSize: 12
                                                }

                                                TextField {
                                                    id: outputPathField
                                                    Layout.fillWidth: true
                                                    text: uvrHelper.getOutputPath()
                                                    color: "#ffffff"
                                                    font.pixelSize: 12
                                                    background: Rectangle {
                                                        color: "#242424"
                                                        border.color: "#404040"
                                                        border.width: 1
                                                        radius: 4
                                                    }
                                                }

                                                Button {
                                                    text: "Browse"
                                                    onClicked: outputPathDialog.open()

                                                    contentItem: Text {
                                                        text: parent.text
                                                        color: "#ffffff"
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    background: Rectangle {
                                                        color: parent.hovered ? "#2c2c2c" : "#242424"
                                                        border.color: "#404040"
                                                        border.width: 1
                                                        radius: 4
                                                    }
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8

                                                Text {
                                                    text: "Output Format:"
                                                    color: "#ffffff"
                                                    font.pixelSize: 12
                                                }

                                                ComboBox {
                                                    id: formatSelector
                                                    Layout.preferredWidth: 120
                                                    model: ["WAV", "MP3", "FLAC"]
                                                    currentIndex: 0

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

                                                Text {
                                                    text: "MP3 Bitrate:"
                                                    color: "#ffffff"
                                                    font.pixelSize: 12
                                                    visible: formatSelector.currentValue === "MP3"
                                                }

                                                SpinBox {
                                                    id: bitrateSelector
                                                    visible: formatSelector.currentValue === "MP3"
                                                    from: 128
                                                    to: 320
                                                    value: 320
                                                    stepSize: 32

                                                    background: Rectangle {
                                                        color: "#242424"
                                                        border.color: "#404040"
                                                        border.width: 1
                                                        radius: 4
                                                    }

                                                    contentItem: TextInput {
                                                        text: parent.textFromValue(parent.value, parent.locale)
                                                        color: "#ffffff"
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
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
        }
    }

    // File Dialogs
    Platform.FileDialog {
        id: fileDialog
        title: "Choose audio files"
        nameFilters: ["Audio files (*.mp3 *.wav *.flac *.m4a)"]
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

    Platform.FolderDialog {
        id: modelPathDialog
        title: "Choose Model Directory"
        folder: modelPathField.text
        onAccepted: {
            modelPathField.text = folder.toString().replace("file://", "")
        }
    }

    Platform.FolderDialog {
        id: outputPathDialog
        title: "Choose Output Directory"
        folder: outputPathField.text
        onAccepted: {
            outputPathField.text = folder.toString().replace("file://", "")
        }
    }

    // UVRHelper Connections
    Connections {
        target: uvrHelper

        function onProcessingStarted() {
            console.log("Processing started")
        }

        function onProcessingFinished(success) {
            console.log("Processing finished:", success)
        }

        function onProgressUpdate(message) {
            console.log("Progress:", message)
        }

        function onErrorOccurred(error) {
            console.error("Error:", error)
        }
    }
}
