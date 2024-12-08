// interface/components/MenuItems.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects  // For Qt6 shadow effects

Rectangle {
    id: mainMenu
    anchors.fill: parent
    color: "#00000000"    // Semi-transparent background
    visible: false
    z: 1000
    property bool isOpen: false

    // Main menu content
    Rectangle {
        id: menuContent
        width: 200
        height: contentColumn.height
        color: "#2d2d2d"
        radius: 4
        border.color: "#404040"
        border.width: 1

        // Shadow effect
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 2
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: "#80000000"
        }

        // Menu items column
        Column {
            id: contentColumn
            width: parent.width
            spacing: 0

            // File Section
            MenuSection {
                title: "File"
                items: [
                    { text: "New Download", shortcut: "Ctrl+N", onClicked: windowController.newDownloadRequested },
                    { separator: true },
                    { text: "Import Links", shortcut: "Ctrl+I", onClicked: windowController.importLinksRequested },
                    { text: "Export History", shortcut: "Ctrl+E", onClicked: windowController.exportHistoryRequested },
                    { separator: true },
                    { text: "Exit", shortcut: "Alt+F4", onClicked: windowController.closeWindow }
                ]
            }

            // Edit Section
            MenuSection {
                title: "Edit"
                items: [
                    { text: "Settings", shortcut: "Ctrl+,", onClicked: windowController.settingsRequested },
                    { text: "Clear History", shortcut: "Ctrl+Shift+Del", onClicked: windowController.clearHistoryRequested }
                ]
            }

            // Tools Section
            MenuSection {
                title: "Tools"
                items: [
                    { text: "Update yt-dlp", onClicked: windowController.updateYtDlpRequested },
                    { text: "Check FFmpeg", onClicked: windowController.checkFFmpegRequested },
                    { separator: true },
                    { text: "Download Manager", shortcut: "Ctrl+D", onClicked: windowController.downloadManagerRequested }
                ]
            }

            // Help Section
            MenuSection {
                title: "Help"
                items: [
                    { text: "Documentation", shortcut: "F1", onClicked: windowController.documentationRequested },
                    { text: "Check for Updates", onClicked: windowController.checkUpdateRequested },
                    { separator: true },
                    { text: "About", onClicked: windowController.aboutRequested },
                    { text: "About Qt", onClicked: windowController.aboutQtRequested }
                ]
            }
        }
    }

    // Close menu when clicking outside
    MouseArea {
        anchors.fill: parent
        onClicked: mainMenu.close()
    }

    function open(x, y) {
        // Add any desired offsets here
        menuContent.x = x + 5 // Example: shift 5 pixels left
        menuContent.y = y + 2 // Example: add 2 pixels gap
        isOpen = true
        visible = true
    }

    function close() {
        isOpen = false
        visible = false
    }

    // Add animations
    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }
}
