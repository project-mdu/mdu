// MainWindow.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "." as Local
import "pages" as Pages

Rectangle {
    id: mainWindow
    color: "#1c1c1c"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Main content
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252525"

            RowLayout {
                anchors.fill: parent
                spacing: 0
                // Main content area
                StackView {
                    id: stackView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    initialItem: downloadsPage
                    Component {
                        id: downloadsPage
                        Pages.Downloads {}
                    }
                }
            }
        }
    }
}
