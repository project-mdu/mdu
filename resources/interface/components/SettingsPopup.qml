// components/SettingsPopup.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic

Popup {
    id: root
    modal: true
    padding: 20
    width: 400
    height: 500

    background: Rectangle {
        color: "#252525"
        radius: 8
        border.color: "#333333"
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 20

        // Header
        Label {
            text: "Extraction Settings"
            font.pixelSize: 16
            color: "#ffffff"
        }

        // Settings Groups
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 20

                // Model Selection
                GroupBox {
                    Layout.fillWidth: true
                    title: "Model"
                    padding: 16

                    background: Rectangle {
                        color: "transparent"
                        border.color: "#333333"
                        radius: 4
                    }

                    label: Label {
                        text: parent.title
                        color: "#ffffff"
                        font.pixelSize: 13
                        padding: 8
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        ComboBox {
                            id: modelCombo
                            Layout.fillWidth: true
                            model: ["Default", "High Quality", "Custom"]

                            background: Rectangle {
                                color: "#1e1e1e"
                                border.color: parent.down ? "#0078D4" : "#333333"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.displayText
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                        }

                        TextField {
                            Layout.fillWidth: true
                            placeholderText: "Custom model path"
                            enabled: modelCombo.currentText === "Custom"
                            color: "#ffffff"

                            background: Rectangle {
                                color: "#1e1e1e"
                                border.color: parent.focus ? "#0078D4" : "#333333"
                                radius: 4
                            }
                        }
                    }
                }

                // Processing Options
                GroupBox {
                    Layout.fillWidth: true
                    title: "Processing"
                    padding: 16

                    background: Rectangle {
                        color: "transparent"
                        border.color: "#333333"
                        radius: 4
                    }

                    label: Label {
                        text: parent.title
                        color: "#ffffff"
                        font.pixelSize: 13
                        padding: 8
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        // Quality Slider
                        Label {
                            text: "Quality"
                            color: "#ffffff"
                            font.pixelSize: 13
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: 75
                            stepSize: 1

                            background: Rectangle {
                                x: parent.leftPadding
                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: parent.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: "#1e1e1e"

                                Rectangle {
                                    width: parent.parent.visualPosition * parent.width
                                    height: parent.height
                                    color: "#0078D4"
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: parent.pressed ? "#005FB3" : "#0078D4"
                            }
                        }

                        // GPU Acceleration
                        CheckBox {
                            text: "Use GPU Acceleration"
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
                    }
                }

                // Output Options
                GroupBox {
                    Layout.fillWidth: true
                    title: "Output"
                    padding: 16

                    background: Rectangle {
                        color: "transparent"
                        border.color: "#333333"
                        radius: 4
                    }

                    label: Label {
                        text: parent.title
                        color: "#ffffff"
                        font.pixelSize: 13
                        padding: 8
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        ComboBox {
                            Layout.fillWidth: true
                            model: ["WAV", "MP3", "FLAC"]

                            background: Rectangle {
                                color: "#1e1e1e"
                                border.color: parent.down ? "#0078D4" : "#333333"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.displayText
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                        }

                        // Output Directory
                        Label {
                            text: "Output Directory"
                            color: "#ffffff"
                            font.pixelSize: 13
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "Choose output directory"
                                color: "#ffffff"
                                readOnly: true

                                background: Rectangle {
                                    color: "#1e1e1e"
                                    border.color: "#333333"
                                    radius: 4
                                }
                            }

                            Button {
                                text: "Browse"

                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.down ? "#005FB3" :
                                           parent.hovered ? "#0078D4" : "#006CC1"
                                    radius: 4
                                }

                                onClicked: {
                                    // Open folder dialog
                                }
                            }
                        }
                    }
                }
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            Button {
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
                }

                onClicked: root.close()
            }

            Button {
                text: "Apply"

                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? "#005FB3" :
                           parent.hovered ? "#0078D4" : "#006CC1"
                    radius: 4
                }

                onClicked: {
                    // Save settings
                    root.close()
                }
            }
        }
    }
}
