import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "." as Local
import "./components" as Components

Item {
    id: root
    anchors.fill: parent
    property Components.About aboutDialog: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Local.HeaderBar {
            id: headerbar
            Layout.fillWidth: true
            Layout.preferredHeight: 32
        }

        Local.MainWindow {
            id: mainWindow
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
