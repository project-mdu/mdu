// MenuSection.qml (create this as a separate component)
import QtQuick 2.15
import QtQuick.Layouts 1.15

Column {
    id: root
    width: parent.width
    spacing: 0

    property string title
    property var items: []

    // Section header
    Rectangle {
        width: parent.width
        height: 32
        color: "transparent"

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: root.title
            font.pixelSize: 12
            font.bold: true
            color: "#cccccc"
        }
    }

    // Menu items
    Repeater {
        model: items

        Loader {
            width: parent.width
            sourceComponent: modelData.separator ? separatorComponent : menuItemComponent
            property var itemData: modelData

            Component {
                id: menuItemComponent
                Rectangle {
                    height: 32
                    color: mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: itemData.text
                            font.pixelSize: 12
                            color: mouseArea.containsMouse ? "#ffffff" : "#cccccc"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: itemData.shortcut || ""
                            font.pixelSize: 11
                            color: mouseArea.containsMouse ? "#ffffff" : "#808080"
                            visible: itemData.shortcut !== undefined
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (itemData.onClicked) {
                                itemData.onClicked()
                                mainMenu.close()
                            }
                        }
                    }

                    // Hover animation
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
            }

            Component {
                id: separatorComponent
                Rectangle {
                    height: 1
                    color: "#404040"
                }
            }
        }
    }
}
