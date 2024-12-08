// interface/models/TypesModel.qml
import QtQuick 2.15

ListModel {
    id: typesModel

    ListElement {
        name: "All files"
        icon: "\uE8B7"  // All files icon
        count: "0"
        type: "all"
    }
    ListElement {
        name: "Videos"
        icon: "\uE8B2"  // Video icon
        count: "0"
        type: "videos"
    }
    ListElement {
        name: "Audio"
        icon: "\uE8D6"  // Audio icon
        count: "0"
        type: "audio"
    }

    function updateCounts(counts) {
        for (let i = 0; i < typesModel.count; i++) {
            let item = typesModel.get(i)
            let type = item.type
            if (counts.hasOwnProperty(type)) {
                typesModel.setProperty(i, "count", counts[type].toString())
            }
        }
    }
}
