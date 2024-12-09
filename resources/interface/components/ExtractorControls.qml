// components/ExtractorControls.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Frame {
    Layout.fillWidth: true
    padding: 16

    signal startExtraction()

    background: Rectangle {
        color: "transparent"
        border.color: "#333333"
        radius: 4
    }

    ColumnLayout {
        width: parent.width
        spacing: 12

        Label {
            text: "Stem Components"
            color: "#ffffff"
            font.pixelSize: 13
        }

        CheckBox {
            id: vocalsCheck
            text: "Vocals"
            checked: true

            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                font.pixelSize: 13
                leftPadding: parent.indicator.width + parent.spacing
                verticalAlignment: Text.AlignVCenter
            }

            indicator: Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: 4
                color: "#1e1e1e"
                border.color: parent.checked ? "#0078D4" : "#333333"

                Rectangle {
                    width: 12
                    height: 12
                    radius: 2
                    anchors.centerIn: parent
                    color: "#0078D4"
                    visible: parent.parent.checked
                }
            }
        }

        CheckBox {
            id: instrumentalsCheck
            text: "Instrumentals"
            checked: true
            // Same styling as vocalsCheck
        }

        CheckBox {
            id: drumsCheck
            text: "Drums"
            checked: true
            // Same styling as vocalsCheck
        }

        CheckBox {
            id: bassCheck
            text: "Bass"
            checked: true
            // Same styling as vocalsCheck
        }

        Item { height: 8 }

        Button {
            text: "Start Extraction"
            Layout.fillWidth: true
            enabled: vocalsCheck.checked || instrumentalsCheck.checked ||
                    drumsCheck.checked || bassCheck.checked

            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: parent.enabled ? 1.0 : 0.5
            }

            background: Rectangle {
                color: parent.enabled ? (parent.down ? "#005FB3" :
                       parent.hovered ? "#0078D4" : "#006CC1") : "#404040"
                radius: 4
            }

            onClicked: startExtraction()
        }
    }
}
