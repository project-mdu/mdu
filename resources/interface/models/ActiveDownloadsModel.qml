// interface/models/ActiveDownloadsModel.qml
import QtQuick 2.15

ListModel {
    ListElement {
        name: "TEST.mp4"
        size: "15.2 MB"
        downloadProgress: 45
        downloadStatus: "3.2 MB/s"
    }
    ListElement {
        name: "Audio.wav"
        size: "2.8 MB"
        downloadProgress: 78
        downloadStatus: "820 KB/s"
    }
    ListElement {
        name: "Videoplayback.mp4"
        size: "102.4 MB"
        downloadProgress: 12
        downloadStatus: "2.1 MB/s"
    }
}
