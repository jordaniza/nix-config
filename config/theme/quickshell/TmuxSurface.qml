pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: surface
    default property alias contents: body.data
    property string summary: ""
    property TmuxAppearance appearance: TmuxAppearance {}
    signal closeRequested()
    implicitHeight: appearance.preferredHeight - 12

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: surface.appearance.contentInset
        spacing: 18
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Text {
                text: "tmux"
                color: Theme.foreground
                font.family: Theme.uiFont
                font.pixelSize: 20
            }
            Text {
                text: surface.summary
                color: Theme.muted
                font.family: Theme.uiFont
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.minimumWidth: 0
                Layout.fillWidth: true
            }
            Button {
                id: closeButton
                objectName: "tmuxClose"
                implicitHeight: 36
                horizontalPadding: 10
                verticalPadding: 6
                focusPolicy: Qt.NoFocus
                hoverEnabled: true
                onClicked: surface.closeRequested()
                background: Rectangle {
                    color: closeButton.down ? Theme.selection : surface.appearance.cardColor
                    radius: Theme.cornerRadius
                    border.width: 1
                    border.color: closeButton.hovered ? Theme.accent : Theme.selection
                }
                contentItem: RowLayout {
                    spacing: 8
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: Theme.cornerRadius
                        color: Theme.background
                        border.width: 1
                        border.color: Theme.selection
                        Text {
                            anchors.centerIn: parent
                            text: "q"
                            font.family: Theme.iconFont
                            font.pixelSize: Theme.fontSize
                            color: Theme.muted
                        }
                    }
                    Text {
                        text: "Close"
                        font.family: Theme.uiFont
                        font.pixelSize: Theme.fontSize
                        color: Theme.foreground
                    }
                }
            }
        }
        Item {
            id: body
            objectName: "tmuxBody"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
