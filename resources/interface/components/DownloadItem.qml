// interface/components/DownloadItem.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    height: 64
    color: Qt.rgba(255, 255, 255, 0.05)
    radius: 4

    property string fileName: ""
    property string fileSize: ""
    property real progress: 0
    property string status: ""

    // Function to determine if file is audio or video
    function getFileType(filename) {
        let ext = filename.split('.').pop().toLowerCase()
        if (/^(mp4|mkv|avi|mov|wmv|flv|webm)$/.test(ext)) {
            return "video"
        } else if (/^(mp3|wav|ogg|m4a|flac|aac)$/.test(ext)) {
            return "audio"
        }
        return "other"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Icon container with vertical centering
        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter

            // Dynamic icon
            Image {
                anchors.fill: parent
                source: {
                    let type = getFileType(fileName)
                    if (type === "video") return "qrc:/image/video.png"
                    if (type === "audio") return "qrc:/image/audio.png"
                    return ""  // Fallback case
                }
                sourceSize.width: 32
                sourceSize.height: 32
                fillMode: Image.PreserveAspectFit
                visible: source !== ""
            }

            // Fallback icon if not audio/video
            Text {
                anchors.centerIn: parent
                text: "\uE8A5"  // Document icon
                font.family: "Segoe Fluent Icons"
                font.pixelSize: 24
                color: "#ffffff"
                visible: getFileType(fileName) === "other"
            }
        }

        // Content container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 4

                Label {
                    text: fileName
                    font.pixelSize: 13
                    color: "#ffffff"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                ProgressBar {
                    from: 0
                    to: 100
                    value: progress
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4

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

                // Status row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: fileSize
                        font.pixelSize: 12
                        color: "#808080"
                    }

                    Label {
                        text: "•"
                        font.pixelSize: 12
                        color: "#808080"
                    }

                    Label {
                        text: status
                        font.pixelSize: 12
                        color: "#808080"
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "\uE711"  // Cancel icon
                        font.family: "Segoe Fluent Icons"
                        font.pixelSize: 12
                        flat: true
                        implicitHeight: 24
                        implicitWidth: 24

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
                    }
                }
            }
        }
    }
}
