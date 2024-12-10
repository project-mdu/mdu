// components/About.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects

Dialog {
    id: root
    title: "About"
    modal: true
    padding: 0
    width: 600
    height: 500
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 200; easing.type: Easing.InCubic }
    }

    background: Rectangle {
        color: "#252525"
        radius: 10
        border.color: "#333333"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#80000000"
            radius: 8.0
            samples: 17
            horizontalOffset: 0
            verticalOffset: 2
        }
    }

    header: Rectangle {
        color: "#2d2d2d"
        height: 48
        radius: 10
        // radius.bottomLeft: 0
        // radius.bottomRight: 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 12

            Text {
                text: "\uE946"
                font.family: "Segoe Fluent Icons"
                font.pixelSize: 16
                color: "#ffffff"
            }

            Label {
                text: root.title
                color: "#ffffff"
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            RoundButton {
                flat: true
                width: 32
                height: 32

                contentItem: Text {
                    text: "\uE8BB"
                    font.family: "Segoe Fluent Icons"
                    font.pixelSize: 10
                    color: parent.hovered ? "#ff4444" : "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                background: Rectangle {
                    radius: width / 2
                    color: parent.hovered ? Qt.rgba(255, 68, 68, 0.1) : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                onClicked: root.close()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 160

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1e1e1e" }
                GradientStop { position: 1.0; color: "#252525" }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                Label {
                    text: "Media Downloader Utility"
                    color: "#ffffff"
                    font.pixelSize: 28
                    font.weight: Font.Medium
                }

                Label {
                    text: "Version 1.0.0"
                    color: "#0078D4"
                    font.pixelSize: 14
                }

                Label {
                    text: "A modern, feature-rich media downloader and processor built with Qt6, featuring downloading, converting, and stem extraction capabilities."
                    color: "#cccccc"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    lineHeight: 1.4
                }

                Label {
                    text: "© 2023 Khaoniewji Development"
                    color: "#808080"
                    font.pixelSize: 12
                }
            }
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 8
            background: Rectangle {
                color: "#252525"
            }

            Repeater {
                model: ["Donators", "Libraries", "Tools"]
                TabButton {
                    text: modelData
                    width: 120

                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#ffffff" : "#808080"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            width: parent.width
                            height: 2
                            anchors.bottom: parent.bottom
                            color: parent.parent.checked ? "#0078D4" : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 8
            currentIndex: tabBar.currentIndex

            // Donators Tab
            Item {
                ScrollView {
                    id: donatorsScrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: donatorsScrollView.width
                        spacing: 12

                        Item { // Top margin
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                        }

                        Label {
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            text: "Special thanks to our supporters"
                            color: "#ffffff"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                        }

                        Repeater {
                            model: ["John Doe - Gold Supporter", "Jane Smith - Silver Supporter"]
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                height: 60
                                radius: 8
                                color: "#2d2d2d"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    Text {
                                        text: "\uE9D9"
                                        font.family: "Segoe Fluent Icons"
                                        font.pixelSize: 20
                                        color: "#FFD700"
                                    }

                                    Label {
                                        text: modelData
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                    }
                                }
                            }
                        }

                        Item { // Bottom margin
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                        }
                    }
                }
            }

            // Libraries Tab
            Item {
                ScrollView {
                    id: librariesScrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: librariesScrollView.width
                        spacing: 16

                        Item { // Top margin
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                        }

                        Repeater {
                            model: [
                                { name: "Qt", version: "6.8.0", description: "Modern C++ GUI framework" },
                                { name: "PyTorch", version: "2.0.0", description: "Deep learning framework for stem extraction" },
                                { name: "FFmpeg", version: "6.0", description: "Multimedia framework for handling video/audio" },
                                { name: "yt-dlp", version: "2024.12.06", description: "Feature-rich video downloader" },
                                { name: "framelesshelper", version: "1.0.0", description: "Modern frameless window implementation" }
                            ]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                height: libLayout.implicitHeight + 32
                                radius: 8
                                color: "#2d2d2d"

                                ColumnLayout {
                                    id: libLayout
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    RowLayout {
                                        spacing: 8
                                        Label {
                                            text: modelData.name
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                        }
                                        Label {
                                            text: modelData.version
                                            color: "#0078D4"
                                            font.pixelSize: 13
                                        }
                                    }

                                    Label {
                                        text: modelData.description
                                        color: "#cccccc"
                                        font.pixelSize: 13
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        Item { // Bottom margin
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                        }
                    }
                }
            }

            // Tools Tab
            Item {
                ScrollView {
                    id: toolsScrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: toolsScrollView.width
                        spacing: 16

                        Item { // Top margin
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                        }

                        Repeater {
                            model: [
                                { name: "Visual Studio 2022", description: "IDE for development" },
                                { name: "Qt Creator", description: "Qt IDE and UI designer" },
                                { name: "CMake", description: "Build system" },
                                { name: "Git", description: "Version control" }
                            ]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                height: toolLayout.implicitHeight + 32
                                radius: 8
                                color: "#2d2d2d"

                                ColumnLayout {
                                    id: toolLayout
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Label {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }

                                    Label {
                                        text: modelData.description
                                        color: "#cccccc"
                                        font.pixelSize: 13
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        Item { // Bottom margin
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                        }
                    }
                }
            }
        }
    }
}
