// interface/components/DownloadModal.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects

Dialog {
    id: root
    title: "Add Download Task"
    modal: true
    padding: 20
    width: 600
    height: 700

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0; to: 1.0
            duration: 200
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            property: "scale"
            from: 0.95; to: 1.0
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0; to: 0.0
            duration: 200
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            property: "scale"
            from: 1.0; to: 0.95
            duration: 200
            easing.type: Easing.InCubic
        }
    }

    anchors.centerIn: parent

    background: Rectangle {
        color: "#252525"
        radius: 8
        border.color: "#333333"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 8.0
            samples: 17
            color: "#80000000"
        }
    }

    header: Rectangle {
        color: "#2d2d2d"
        height: 48
        radius: 8

        Label {
            text: root.title
            color: "#ffffff"
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    contentItem: ScrollView {
        id: scrollView
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: scrollView.width - 20
            spacing: 20

            // URL Input Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "URL"
                    color: "#ffffff"
                    font.pixelSize: 13
                }

                TextField {
                    id: urlInput
                    Layout.fillWidth: true
                    height: 36
                    placeholderText: "Enter URL"
                    color: "#ffffff"
                    placeholderTextColor: "#808080"
                    selectByMouse: true

                    background: Rectangle {
                        color: "#1e1e1e"
                        border.color: parent.focus ? "#0078D4" : "#333333"
                        border.width: 1
                        radius: 4
                    }
                }
            }
            // Video Settings Group
                       GroupBox {
                           Layout.fillWidth: true
                           padding: 16
                           title: "Video Settings"

                           background: Rectangle {
                               color: "transparent"
                               border.color: "#333333"
                               radius: 4
                           }

                           label: Label {
                               text: parent.title
                               color: "#ffffff"
                               x:16
                               y:8
                               font.pixelSize: 13
                               font.bold: true
                           }

                           ColumnLayout {
                               width: parent.width
                               spacing: 16

                               // Video Resolution
                               ColumnLayout {
                                   Layout.fillWidth: true
                                   spacing: 8

                                   Label {
                                       text: "Video Resolution"
                                       color: "#ffffff"
                                       font.pixelSize: 13
                                       x:16
                                   }

                                   ComboBox {
                                       id: resolutionCombo
                                       Layout.fillWidth: true
                                       model: ["Auto", "4K", "1440p", "1080p", "720p", "480p", "360p"]
                                       leftPadding: 8

                                       background: Rectangle {
                                           color: "#1e1e1e"
                                           border.color: parent.down ? "#0078D4" : "#333333"
                                           radius: 4
                                       }

                                       contentItem: Text {
                                           text: resolutionCombo.displayText
                                           color: "#ffffff"
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                   }
                               }

                               // Framerate
                               RowLayout {
                                   Layout.fillWidth: true
                                   spacing: 8

                                   CheckBox {
                                       id: framerateCheck
                                       text: "Framerate"
                                       checked: false
                                       spacing: 8
                                       leftPadding: 24

                                       contentItem: Text {
                                           text: parent.text
                                           color: "#ffffff"
                                           font.pixelSize: 13
                                           verticalAlignment: Text.AlignVCenter
                                           x: parent.indicator.width + parent.spacing
                                           anchors.leftMargin: parent.spacing
                                       }

                                       indicator: Rectangle {
                                           implicitWidth: 20
                                           implicitHeight: 20
                                           x: 0
                                           y: parent.height / 2 - height / 2
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

                                   ComboBox {
                                       id: framerateCombo
                                       Layout.fillWidth: true
                                       enabled: framerateCheck.checked
                                       model: ["60fps", "30fps"]
                                       opacity: enabled ? 1.0 : 0.5
                                       leftPadding: 8

                                       background: Rectangle {
                                           color: "#1e1e1e"
                                           border.color: parent.down ? "#0078D4" : "#333333"
                                           opacity: parent.enabled ? 1.0 : 0.5
                                           radius: 4
                                       }

                                       contentItem: Text {
                                           text: framerateCombo.displayText
                                           color: "#ffffff"
                                           opacity: framerateCombo.enabled ? 1.0 : 0.5
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                   }
                               }
                           }
                       }

                       // Audio Settings Group
                       GroupBox {
                           Layout.fillWidth: true
                           padding: 16
                           title: "Audio Settings"

                           background: Rectangle {
                               color: "transparent"
                               border.color: "#333333"
                               radius: 4
                           }

                           label: Label {
                               text: parent.title
                               color: "#ffffff"
                               x:16
                               y:8
                               font.pixelSize: 13
                               font.bold: true
                           }

                           ColumnLayout {
                               width: parent.width
                               spacing: 16

                               RowLayout {
                                   Layout.fillWidth: true
                                   spacing: 8

                                   CheckBox {
                                       id: audioOnlyCheck
                                       text: "Audio Only"
                                       checked: false
                                       spacing: 8
                                       leftPadding: 24

                                       contentItem: Text {
                                           text: parent.text
                                           color: "#ffffff"
                                           font.pixelSize: 13
                                           verticalAlignment: Text.AlignVCenter
                                           x: parent.indicator.width + parent.spacing
                                           anchors.leftMargin: parent.spacing
                                       }

                                       indicator: Rectangle {
                                           implicitWidth: 20
                                           implicitHeight: 20
                                           x: 0
                                           y: parent.height / 2 - height / 2
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

                                   ComboBox {
                                       id: audioFormatCombo
                                       Layout.fillWidth: true
                                       enabled: audioOnlyCheck.checked
                                       model: ["MP3", "AAC", "WAV", "OPUS"]
                                       opacity: enabled ? 1.0 : 0.5
                                       leftPadding: 8

                                       background: Rectangle {
                                           color: "#1e1e1e"
                                           border.color: parent.down ? "#0078D4" : "#333333"
                                           opacity: parent.enabled ? 1.0 : 0.5
                                           radius: 4
                                       }

                                       contentItem: Text {
                                           text: audioFormatCombo.displayText
                                           color: "#ffffff"
                                           opacity: audioFormatCombo.enabled ? 1.0 : 0.5
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                   }
                               }
                           }
                       }
                       // Advanced Settings Group
                                   GroupBox {
                                       Layout.fillWidth: true
                                       padding: 16
                                       title: "Advanced Settings"

                                       background: Rectangle {
                                           color: "transparent"
                                           border.color: "#333333"
                                           radius: 4
                                       }

                                       label: Label {
                                           text: parent.title
                                           color: "#ffffff"
                                           font.pixelSize: 13
                                           x:16
                                           y:8
                                           font.bold: true
                                       }

                                       ColumnLayout {
                                           width: parent.width
                                           spacing: 16

                                           // Additional Options
                                           ColumnLayout {
                                               spacing: 8

                                               CheckBox {
                                                   id: thumbnailCheck
                                                   text: "Download with thumbnails"
                                                   checked: false
                                                   spacing: 8
                                                   leftPadding: 24

                                                   contentItem: Text {
                                                       text: parent.text
                                                       color: "#ffffff"
                                                       font.pixelSize: 13
                                                       verticalAlignment: Text.AlignVCenter
                                                       x: parent.indicator.width + parent.spacing
                                                       anchors.leftMargin: parent.spacing
                                                   }

                                                   indicator: Rectangle {
                                                       implicitWidth: 20
                                                       implicitHeight: 20
                                                       x: 0
                                                       y: parent.height / 2 - height / 2
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
                                                   id: playlistCheck
                                                   text: "Download as playlist"
                                                   checked: false
                                                   spacing: 8
                                                   leftPadding: 24

                                                   contentItem: Text {
                                                       text: parent.text
                                                       color: "#ffffff"
                                                       font.pixelSize: 13
                                                       verticalAlignment: Text.AlignVCenter
                                                       x: parent.indicator.width + parent.spacing
                                                       anchors.leftMargin: parent.spacing
                                                   }

                                                   indicator: Rectangle {
                                                       implicitWidth: 20
                                                       implicitHeight: 20
                                                       x: 0
                                                       y: parent.height / 2 - height / 2
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
                                           }

                                           // Encoding Options
                                           ColumnLayout {
                                               Layout.fillWidth: true
                                               spacing: 8

                                               CheckBox {
                                                   id: encodingCheck
                                                   text: "Enable encoding"
                                                   checked: false
                                                   spacing: 8
                                                   leftPadding: 24

                                                   contentItem: Text {
                                                       text: parent.text
                                                       color: "#ffffff"
                                                       font.pixelSize: 13
                                                       verticalAlignment: Text.AlignVCenter
                                                       x: parent.indicator.width + parent.spacing
                                                       anchors.leftMargin: parent.spacing
                                                   }

                                                   indicator: Rectangle {
                                                       implicitWidth: 20
                                                       implicitHeight: 20
                                                       x: 0
                                                       y: parent.height / 2 - height / 2
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

                                               ColumnLayout {
                                                   Layout.fillWidth: true
                                                   spacing: 8
                                                   enabled: encodingCheck.checked
                                                   opacity: encodingCheck.checked ? 1.0 : 0.5


                                                   RowLayout {
                                                       Layout.fillWidth: true
                                                       spacing: 8

                                                       Label {
                                                           text: "Codec"
                                                           color: "#ffffff"
                                                           font.pixelSize: 13
                                                           Layout.preferredWidth: 80
                                                       }

                                                       ComboBox {
                                                           id: codecCombo
                                                           Layout.fillWidth: true
                                                           model: ["H.264", "H.265", "VP9"]
                                                           leftPadding: 8

                                                           background: Rectangle {
                                                               color: "#1e1e1e"
                                                               border.color: parent.down ? "#0078D4" : "#333333"
                                                               radius: 4
                                                           }

                                                           contentItem: Text {
                                                               text: codecCombo.displayText
                                                               color: "#ffffff"
                                                               verticalAlignment: Text.AlignVCenter
                                                           }
                                                       }
                                                   }

                                                   RowLayout {
                                                       Layout.fillWidth: true
                                                       spacing: 8

                                                       Label {
                                                           text: "Bitrate"
                                                           color: "#ffffff"
                                                           font.pixelSize: 13
                                                           Layout.preferredWidth: 80
                                                       }

                                                       ComboBox {
                                                           id: bitrateCombo
                                                           Layout.fillWidth: true
                                                           model: ["Auto", "1000k", "2000k", "4000k", "8000k"]
                                                           leftPadding:8

                                                           background: Rectangle {
                                                               color: "#1e1e1e"
                                                               border.color: parent.down ? "#0078D4" : "#333333"
                                                               radius: 4
                                                           }

                                                           contentItem: Text {
                                                               text: bitrateCombo.displayText
                                                               color: "#ffffff"
                                                               verticalAlignment: Text.AlignVCenter
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }

                                   Item { Layout.fillHeight: true } // Spacer
                               }
                           }

                           footer: Rectangle {
                               color: "#2d2d2d"
                               height: 64
                               radius: 8

                               RowLayout {
                                   anchors.fill: parent
                                   anchors.margins: 16
                                   spacing: 8

                                   Item { Layout.fillWidth: true }

                                   Button {
                                       id: cancelButton
                                       text: "Cancel"
                                       flat: true

                                       contentItem: Text {
                                           text: parent.text
                                           color: "#ffffff"
                                           horizontalAlignment: Text.AlignHCenter
                                           verticalAlignment: Text.AlignVCenter
                                       }

                                       background: Rectangle {
                                           color: parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                                           radius: 4

                                           Behavior on color {
                                               ColorAnimation { duration: 150 }
                                           }
                                       }

                                       onClicked: root.reject()
                                   }

                                   Button {
                                       id: downloadButton
                                       text: "Download"
                                       enabled: urlInput.text.length > 0

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

                                           Behavior on color {
                                               ColorAnimation { duration: 150 }
                                           }
                                       }

                                       onClicked: {
                                           if (urlInput.text.length > 0) {
                                               let downloadConfig = {
                                                   url: urlInput.text,
                                                   resolution: resolutionCombo.currentText,
                                                   framerate: framerateCheck.checked ? framerateCombo.currentText : "auto",
                                                   audioOnly: audioOnlyCheck.checked,
                                                   audioFormat: audioFormatCombo.currentText,
                                                   withThumbnails: thumbnailCheck.checked,
                                                   asPlaylist: playlistCheck.checked,
                                                   encoding: encodingCheck.checked ? {
                                                       codec: codecCombo.currentText,
                                                       bitrate: bitrateCombo.currentText
                                                   } : null
                                               }
                                               console.log(JSON.stringify(downloadConfig, null, 2))
                                               root.accept()
                                           }
                                       }
                                   }
                               }
                           }

                           // Reset form when closing
                           onClosed: {
                               urlInput.text = ""
                               resolutionCombo.currentIndex = 0
                               framerateCheck.checked = false
                               framerateCombo.currentIndex = 0
                               audioOnlyCheck.checked = false
                               audioFormatCombo.currentIndex = 0
                               thumbnailCheck.checked = false
                               playlistCheck.checked = false
                               encodingCheck.checked = false
                               codecCombo.currentIndex = 0
                               bitrateCombo.currentIndex = 0
                           }
}
