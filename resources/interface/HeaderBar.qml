// HeaderBar.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import "./components" as Components

Rectangle {
    id: headerbar
    color: "#2d2d2d"
    height: 32
    z: 100

    // Add property at Rectangle scope
    property int currentIndex: 0

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: 45
        onPressed: windowController.moveWindow()
        onDoubleClicked: windowController.maximizeWindow()
        onClicked: mouse.accepted = true
    }

    Components.MenuItems {
        id: mainMenu
        z: 1000
        y: headerbar.height
    }

    Overlay.modal: Rectangle {
        color: "#80000000"
        z: 999
    }

    Overlay.modeless: Rectangle {
        color: "transparent"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Section - Menu and Title
        RowLayout {
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignLeft
            spacing: 0

            Button {
                id: menuButton
                Layout.preferredWidth: 45
                Layout.preferredHeight: 32
                flat: true
                z: 101

                contentItem: Text {
                    text: "\uE700"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 10
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down || mainMenu.isOpen ? Qt.rgba(255, 255, 255, 0.1) :
                           parent.hovered ? Qt.rgba(255, 255, 255, 0.05) : "transparent"
                }
                onClicked: {
                    if (mainMenu.isOpen) {
                        mainMenu.close()
                    } else {
                        var pos = menuButton.mapToItem(null, 0, 0)
                        mainMenu.open(pos.x, pos.y + menuButton.height)
                    }
                }
            }

            Label {
                text: "Media Downloader Utility"
                color: "#ffffff"
                font.pixelSize: 12
                Layout.leftMargin: 8
            }
        }

        // Center Section - Navigation
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            spacing: 20

            Repeater {
                model: ["Downloader", "Converter", "Stem Extractor"]

                Button {
                    id: navButton
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    flat: true

                    contentItem: Text {
                        text: modelData
                        color: navButton.checked ? "#ffffff" : "#cccccc"
                        font.pixelSize: 12
                        font.weight: 600
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            width: parent.width
                            height: 2
                            anchors.bottom: parent.bottom
                            color: navButton.checked ? "#ffffff" : "transparent"
                        }
                    }

                    checkable: true
                    autoExclusive: true
                    checked: {
                        switch(modelData.toLowerCase()) {
                            case "downloader":
                                return mainWindow.currentPage === "downloadsPage"
                            case "converter":
                                return mainWindow.currentPage === "converterPage"
                            case "stem extractor":
                                return mainWindow.currentPage === "stemExtractorPage"
                            default:
                                return false
                        }
                    }

                    onClicked: mainWindow.switchPage(modelData)
                }
            }
        }

        // Right Section - Window Controls
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 0

            Button {
                id: minimizeButton
                Layout.preferredWidth: 45
                Layout.preferredHeight: 32
                flat: true

                contentItem: Text {
                    text: "\uE921"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 10
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                }

                onClicked: windowController.minimizeWindow()
            }

            Button {
                id: maximizeButton
                Layout.preferredWidth: 45
                Layout.preferredHeight: 32
                flat: true
                property bool isMaximized: windowController.isMaximized

                contentItem: Text {
                    text: maximizeButton.isMaximized ? "\uE923" : "\uE922"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 10
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                }

                onClicked: windowController.maximizeWindow()
            }

            Button {
                id: closeButton
                Layout.preferredWidth: 45
                Layout.preferredHeight: 32
                flat: true

                contentItem: Text {
                    text: "\uE8BB"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 10
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? "#c42b1c" : "transparent"
                }

                onClicked: windowController.closeWindow()
            }
        }
    }
}
