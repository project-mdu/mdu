// components/ProgressPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic

Rectangle {
    id: root
    color: "#1e1e1e"

    required property var activeModel
    required property var completedModel

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Active Extractions
        Column {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "In Progress"
                font.pixelSize: 14
                color: "#ffffff"
            }

            ListView {
                width: parent.width
                height: contentHeight
                model: root.activeModel
                spacing: 8
                interactive: false
                visible: root.activeModel.count > 0

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 80
                    color: Qt.rgba(255, 255, 255, 0.05)
                    radius: 4

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Label {
                            text: fileName
                            font.pixelSize: 13
                            color: "#ffffff"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            value: progress

                            background: Rectangle {
                                implicitHeight: 4
                                color: Qt.rgba(255, 255, 255, 0.1)
                                radius: 2
                            }

                            contentItem: Item {
                                implicitHeight: 4

                                Rectangle {
                                    width: parent.width * progress / 100
                                    height: parent.height
                                    radius: 2
                                    color: "#0078D4"
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: status
                                font.pixelSize: 12
                                color: "#808080"
                            }

                            Item { Layout.fillWidth: true }

                            Button {
                                text: "\uE711"  // Cancel icon
                                font.family: "Segoe Fluent Icons"
                                flat: true

                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: "#ffffff"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                                    radius: 2
                                }

                                onClicked: root.activeModel.remove(index)
                            }
                        }
                    }
                }
            }

            // Empty state for Active
            Rectangle {
                width: parent.width
                height: 60
                color: Qt.rgba(255, 255, 255, 0.05)
                radius: 4
                visible: root.activeModel.count === 0

                Label {
                    anchors.centerIn: parent
                    text: "No active extractions"
                    color: "#808080"
                    font.pixelSize: 13
                }
            }
        }

        // Completed
        Column {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Label {
                text: "Completed"
                font.pixelSize: 14
                color: "#ffffff"
            }

            ListView {
                width: parent.width
                height: parent.height - 30
                clip: true
                model: root.completedModel
                spacing: 8
                visible: root.completedModel.count > 0

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 64
                    color: Qt.rgba(255, 255, 255, 0.05)
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: "\uE8A5"  // Audio icon
                            font.family: "Segoe Fluent Icons"
                            font.pixelSize: 24
                            color: "#ffffff"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: fileName
                                font.pixelSize: 13
                                color: "#ffffff"
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
                            }

                            Label {
                                text: components
                                font.pixelSize: 12
                                color: "#808080"
                            }
                        }

                        Button {
                            text: "\uE8DA"  // Folder icon
                            font.family: "Segoe Fluent Icons"
                            flat: true

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

                            onClicked: {
                                // Open output folder
                            }
                        }
                    }
                }
            }

            // Empty state for Completed
            Rectangle {
                width: parent.width
                height: parent.height - 30
                color: Qt.rgba(255, 255, 255, 0.05)
                radius: 4
                visible: root.completedModel.count === 0

                Label {
                    anchors.centerIn: parent
                    text: "No completed extractions"
                    color: "#808080"
                    font.pixelSize: 13
                }
            }
        }
    }
}
