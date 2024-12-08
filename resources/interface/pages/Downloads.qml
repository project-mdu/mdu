// interface/pages/Downloads.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
import "../models" as Modelx
import "../components" as Components

Page {
    id: root

    property bool isLoading: false
    property var downloadData: []

    Component.onCompleted: {
        loadDownloadHistory()
    }

    Components.DownloadModal {
        id: downloadModal

        onAccepted: {
            // Handle download configuration
            console.log("Starting download with config")
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
                    filePath: data[i].path
                })
            }

            updateTypesCounts()
            isLoading = false
        }

        function onLoadingError(error) {
            isLoading = false
            console.error("Error loading downloads:", error)
            // You might want to show an error message to the user here
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

            if (fileType.match("video")) {
                counts.videos++
            } else if (fileType.match("audio")) {
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
                    text: "\uE710"  // Add icon
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

                    onClicked: {
                        // TODO: Implement add task functionality
                        onClicked: downloadModal.open()
                    }
                }

                // Stop All Button
                Button {
                    text: "\uE71A"  // Stop icon
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
                    ToolTip.text: "Stop All"

                    onClicked: {
                        // TODO: Implement stop all functionality
                        console.log("Stop all clicked")
                    }
                }

                // Clear All Button
                Button {
                    text: "\uE74D"
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
                    ToolTip.text: "Clear all"

                    onClicked: {
                        // TODO: Implement clear all functionality
                        console.log("Clear all clicked")
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

                    // BusyIndicator {
                    //     anchors.centerIn: parent
                    //     running: isLoading

                    //     contentItem: Item {
                    //         implicitWidth: 64
                    //         implicitHeight: 64

                    //         Item {
                    //             id: item
                    //             width: 64
                    //             height: 64
                    //             anchors.centerIn: parent
                    //             opacity: parent.opacity

                    //             RotationAnimator {
                    //                 target: item
                    //                 running: isLoading
                    //                 from: 0
                    //                 to: 360
                    //                 duration: 1500
                    //                 loops: Animation.Infinite
                    //             }

                    //             Repeater {
                    //                 model: 8
                    //                 Rectangle {
                    //                     x: item.width/2 - width/2
                    //                     y: item.height/2 - height/2
                    //                     width: 4
                    //                     height: 16
                    //                     radius: 2
                    //                     color: "#ffffff"
                    //                     transform: [
                    //                         Translate {
                    //                             y: -24
                    //                         },
                    //                         Rotation {
                    //                             angle: index * 45
                    //                             origin.x: 2
                    //                             origin.y: 24
                    //                         }
                    //                     ]
                    //                     opacity: 0.25 + (index + 1) * 0.1
                    //                 }
                    //             }
                    //         }
                    //     }
                    // }

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
                            // TODO: Implement search functionality
                            console.log("Search text changed:", text)
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
                                fileSize: model.fileType
                                progress: 100
                                status: "Completed"

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
