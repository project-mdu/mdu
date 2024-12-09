import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: fileItem
    width: ListView.view.width
    height: 64
    color: Qt.rgba(255, 255, 255, 0.05)
    radius: 4

    // Define the signal with index parameter
    signal requestRemove(int itemIndex)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Text {
            text: "\uE8A5"  // Audio file icon
            font.family: "Segoe Fluent Icons"
            font.pixelSize: 24
            color: "#ffffff"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: model.fileName || ""
                font.pixelSize: 13
                color: "#ffffff"
                Layout.fillWidth: true
                elide: Text.ElideMiddle
            }

            Label {
                text: model.fileSize || ""
                font.pixelSize: 12
                color: "#808080"
            }
        }

        Button {
            text: "\uE74D"  // Remove icon
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

            onClicked: fileItem.requestRemove(model.index)
        }
    }
}
