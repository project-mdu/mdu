// components/FilesList.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    color: "#1e1e1e"

    required property ListModel filesModel
    signal removeRequested(int index)
    signal extractionRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        ListView {
            id: filesListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: root.filesModel

            delegate: FileItem {
                // Connect the signal
                onRequestRemove: function(itemIndex) {
                    root.removeRequested(itemIndex)
                }
            }

            // Empty State
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(255, 255, 255, 0.05)
                radius: 4
                visible: root.filesModel.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "\uE8A5"
                        font.family: "Segoe Fluent Icons"
                        font.pixelSize: 32
                        color: "#808080"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Drop audio files here"
                        font.pixelSize: 14
                        color: "#808080"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        ExtractorControls {
            Layout.fillWidth: true
            onStartExtraction: root.extractionRequested()
        }
    }
}
