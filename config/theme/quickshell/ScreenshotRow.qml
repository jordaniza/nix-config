pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ItemDelegate {
    id: row
    required property url imageSource
    required property string timestamp
    property bool selected: false
    readonly property int previewHeight: 170
    horizontalPadding: 10
    verticalPadding: 8
    focusPolicy: Qt.NoFocus
    hoverEnabled: true

    background: Rectangle {
        radius: Theme.cornerRadius
        color: row.selected || row.hovered ? Theme.selection : Theme.transparent
        border.width: row.selected ? 1 : 0
        border.color: Theme.accent
    }
    contentItem: ColumnLayout {
        spacing: 6
        Image {
            id: preview
            Layout.fillWidth: true
            Layout.preferredHeight: row.previewHeight
            source: row.imageSource
            asynchronous: true
            cache: false
            sourceSize.width: Math.ceil(row.availableWidth)
            sourceSize.height: row.previewHeight
            fillMode: Image.PreserveAspectFit
            ListMessage {
                anchors.centerIn: parent
                width: parent.width
                text: "Preview unavailable"
                visible: preview.status === Image.Error
            }
        }
        Text {
            Layout.fillWidth: true
            text: row.text
            textFormat: Text.PlainText
            elide: Text.ElideMiddle
            font.family: Theme.uiFont
            font.pixelSize: Theme.fontSize
            color: Theme.foreground
        }
        Text {
            Layout.fillWidth: true
            text: row.timestamp
            textFormat: Text.PlainText
            font.family: Theme.uiFont
            font.pixelSize: Theme.fontSize
            color: Theme.foreground
        }
    }
}
