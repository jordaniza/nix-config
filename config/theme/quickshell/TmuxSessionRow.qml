pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    required property var session
    required property string age
    property TmuxAppearance appearance: TmuxAppearance {}
    implicitHeight: appearance.cardHeightFor(session.windows.length)
    radius: Theme.cornerRadius
    color: appearance.cardColor
    border.width: 1
    border.color: Theme.selection

    RowLayout {
        id: heading
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: card.appearance.cardInset
        height: card.appearance.cardHeaderHeight
        spacing: 8
        Text {
            text: card.session.attached ? "●" : "○"
            color: card.session.attached ? Theme.accent : Theme.muted
            font.family: Theme.uiFont
            font.pixelSize: Theme.fontSize
        }
        Text {
            text: card.session.attached ? "Attached" : "Detached"
            color: Theme.foreground
            font.family: Theme.uiFont
            font.pixelSize: 16
            Layout.fillWidth: true
        }
    }
    RowLayout {
        id: metadata
        anchors.top: heading.bottom
        anchors.left: heading.left
        anchors.right: heading.right
        height: card.appearance.cardMetaHeight
        spacing: 8
        Text {
            text: card.session.windows.length + (card.session.windows.length === 1 ? " window" : " windows")
            color: Theme.muted
            font.family: Theme.uiFont
            font.pixelSize: 12
            Layout.fillWidth: true
        }
        Text {
            text: "Created " + card.age + " ago"
            color: Theme.muted
            font.family: Theme.uiFont
            font.pixelSize: 12
        }
    }
    Rectangle {
        id: separator
        anchors.top: metadata.bottom
        anchors.topMargin: card.appearance.cardSectionGap
        anchors.left: heading.left
        anchors.right: heading.right
        height: 1
        color: Theme.selection
    }
    Column {
        id: windows
        anchors.top: separator.bottom
        anchors.topMargin: card.appearance.cardSectionGap - 1
        anchors.left: heading.left
        anchors.right: heading.right
        spacing: card.appearance.windowSpacing
        Repeater {
            model: card.session.windows
            RowLayout {
                required property var modelData
                objectName: "tmuxWindow_" + card.session.id + "_" + modelData.index
                width: windows.width
                height: card.appearance.windowHeight
                spacing: 12
                Text {
                    text: String(modelData.index).padStart(2, "0")
                    color: Theme.muted
                    font.family: Theme.iconFont
                    font.pixelSize: 12
                    Layout.preferredWidth: 24
                }
                Text {
                    objectName: "windowName"
                    text: modelData.name
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: Theme.foreground
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.fontSize
                    Layout.minimumWidth: 0
                    Layout.fillWidth: true
                }
            }
        }
    }
}
