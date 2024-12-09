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

    // Models
    ListModel { id: filesModel }
    ListModel { id: activeModel }
    ListModel { id: completedModel }

    Rectangle {
        anchors.fill: parent
        color: "#161616"  // Slightly darker base color

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

                        // Empty state
                        // Empty state with Drag and Drop support
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

                                                    // Drag and Drop Area
                                                    DropArea {
                                                        id: dropArea
                                                        anchors.fill: parent
                                                        keys: ["text/uri-list"]

                                                        onDropped: (drop) => {
                                                            // Process dropped files
                                                            if (drop.hasUrls) {
                                                                for (let i = 0; i < drop.urls.length; i++) {
                                                                    let filePath = drop.urls[i].toString()
                                                                    filePath = filePath.replace(/^(file:\/{3})/, "")

                                                                    // Check file extension
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
                                                            // Optional: you could add additional validation here
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
                                    model: ["Drums", "Bass", "Guitar", "Vocals", "Other"]

                                    CheckBox {
                                        text: modelData
                                        checked: index < 4  // First 4 checked by default

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
                            spacing: 600

                            Text {
                                text: "Progress"
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                font.weight: Font.Medium
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
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    indicator: Item {} // Empty item effectively removes the arrow

                                    // Enhanced model handling
                                    model: {
                                        // Ensure devices are available, otherwise provide a fallback
                                        deviceManager.availableDevices.length > 0
                                            ? deviceManager.availableDevices
                                            : ["CPU"]
                                    }

                                    // Improved current index selection with fallback
                                    currentIndex: {
                                        const currentDevice = deviceManager.currentDevice
                                        const index = model.indexOf(currentDevice)
                                        return index !== -1 ? index : 0
                                    }

                                    // More robust device selection
                                    onCurrentValueChanged: {
                                        // Validate before changing
                                        if (currentValue && deviceManager.availableDevices.includes(currentValue)) {
                                            deviceManager.currentDevice = currentValue

                                            // Optional: Log device change or show a temporary notification
                                            console.log("Device changed to: " + currentValue)
                                        }
                                    }

                                    // Add a tooltip to show current device details
                                    ToolTip {
                                        id: deviceTooltip
                                        text: {
                                            // Try to get GPU details if GPU is selected
                                            if (deviceSelector.currentValue === "GPU") {
                                                const details = deviceManager.getDeviceDetails(1) // GPU is typically index 1
                                                return details
                                                    ? `GPU: ${details.name}\nMemory: ${(details.memorySize / (1024 * 1024)).toFixed(0)} MB`
                                                    : "GPU details unavailable"
                                            }
                                            return ""
                                        }
                                        visible: deviceSelector.hovered && text !== ""
                                    }

                                    // Visual indicator for device type
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.rightMargin: 8
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: {
                                            switch(deviceSelector.currentValue) {
                                            case "GPU": return "#4CAF50"  // Green for GPU
                                            case "NPU": return "#2196F3"  // Blue for NPU
                                            default: return "#FF9800"     // Orange for CPU
                                            }
                                        }
                                    }

                                    // Error handling placeholder
                                    Text {
                                        anchors.centerIn: parent
                                        text: deviceManager.availableDevices.length === 0
                                              ? "No devices detected"
                                              : ""
                                        color: "red"
                                        visible: text !== ""
                                    }

                                    // Existing styling remains the same...
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

                                    delegate: ItemDelegate {
                                        width: deviceSelector.width
                                        height: 32
                                        contentItem: Text {
                                            text: modelData
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        background: Rectangle {
                                            color: parent.hovered ? "#2c2c2c" : "#242424"
                                        }
                                    }

                                    popup: Popup {
                                        y: deviceSelector.height
                                        width: deviceSelector.width
                                        padding: 1
                                        background: Rectangle {
                                            color: "#242424"
                                            border.color: "#404040"
                                            border.width: 1
                                            radius: 4
                                        }
                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: deviceSelector.popup.visible ? deviceSelector.delegateModel : null
                                        }
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
                                        width: parent.width * parent.parent.visualPosition
                                        height: 4
                                        radius: 2
                                        color: "#0078D4"
                                    }
                                }

                                // Task details (extraction types)
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
        }
    }

    // File Dialog
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
    Connections {
        target: deviceManager

        // Handle available devices changing
        function onAvailableDevicesChanged() {
            deviceSelector.model = deviceManager.availableDevices
        }

        // Optional: Handle current device changing
        function onCurrentDeviceChanged() {
            deviceSelector.currentIndex = deviceSelector.model.indexOf(deviceManager.currentDevice)
        }
    }
}
