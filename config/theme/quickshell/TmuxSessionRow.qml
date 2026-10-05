pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: row
    required property var session
    required property string age
    height: implicitHeight
    horizontalPadding: 8
    verticalPadding: 6
    background: null

    contentItem: ColumnLayout {
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text {
                Layout.preferredWidth: 16
                text: row.session.attached ? "●" : "○"
                color: row.session.attached ? Theme.accent : Theme.muted
                font.family: Theme.uiFont
                font.pixelSize: Theme.fontSize
            }
            Text {
                Layout.fillWidth: true
                text: row.session.windows.length + (row.session.windows.length === 1 ? " window" : " windows")
                color: Theme.foreground
                font.family: Theme.uiFont
                font.pixelSize: Theme.fontSize
            }
            Text {
                text: row.age
                color: Theme.muted
                font.family: Theme.uiFont
                font.pixelSize: Theme.fontSize
            }
        }
        Repeater {
            model: row.session.windows
            Text {
                required property var modelData
                Layout.fillWidth: true
                Layout.leftMargin: 24
                text: modelData.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.foreground
                font.family: Theme.uiFont
                font.pixelSize: Theme.fontSize
            }
        }
    }
}
