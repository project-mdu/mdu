// pages/Converter.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    objectName: "converterPage"
    padding: 0

    Rectangle {
        anchors.fill: parent
        color: "#1e1e1e"

        Label {
            anchors.centerIn: parent
            text: "Converter Page"
            color: "#ffffff"
            font.pixelSize: 16
        }
    }
}
