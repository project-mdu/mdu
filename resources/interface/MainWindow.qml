// MainWindow.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import "." as Local
import "pages" as Pages

Rectangle {
    id: mainWindow
    color: "#1c1c1c"

    property string currentPage: "downloadsPage"
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252525"

            Loader {
                id: pageLoader
                anchors.fill: parent
                source: "pages/Downloads.qml"
            }
        }
    }

    function switchPage(pageName) {
        let page = ""
        switch(pageName.toLowerCase()) {
            case "downloader":
                page = "pages/Downloads.qml"
                currentPage = "downloadsPage"
                break
            case "converter":
                page = "pages/Converter.qml"
                currentPage = "converterPage"
                break
            case "stem extractor":
                page = "pages/StemExtractor.qml"
                currentPage = "stemExtractorPage"
                break
        }
        pageLoader.setSource(page)
    }
}
