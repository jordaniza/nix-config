pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import "../../shared"
import "../../theme"

ActionList {
    id: list
    required property url folder
    interactive: true
    wrapNavigation: false
    reuseItems: true
    keyAtIndex: index => files.get(index, "filePath")
    model: FolderListModel {
        id: files
        folder: list.folder
        nameFilters: ["*.png"]
        showDirs: false
        sortField: FolderListModel.Time
        onStatusChanged: if (status === FolderListModel.Ready)
            list.currentIndex = count > 0 ? 0 : -1
    }
    delegate: ScreenshotRow {
        required property int index
        required property url fileUrl
        required property string fileName
        required property date fileModified
        width: list.width
        imageSource: fileUrl
        text: fileName
        timestamp: Qt.formatDateTime(fileModified, "ddd d MMM yyyy · HH:mm:ss")
        selected: list.currentIndex === index
        enabled: list.actionsEnabled
        onClicked: {
            list.currentIndex = index;
            list.activate(index);
        }
    }
    ListMessage {
        parent: list
        anchors.centerIn: parent
        width: parent.width
        text: files.status === FolderListModel.Loading ? "Loading…" : "No screenshots"
        visible: list.count === 0
    }
}
