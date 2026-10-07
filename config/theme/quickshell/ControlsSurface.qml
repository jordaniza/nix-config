pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: surface
    signal closeRequested()
    signal actionRequested(string key)
    property var actions: []
    property bool actionsEnabled: true
    property string errorMessage: ""
    readonly property int contentInset: 22
    property LauncherAppearance appearance: LauncherAppearance {}
    readonly property color buttonColor: Qt.tint(Theme.background,
        Qt.rgba(Theme.selection.r, Theme.selection.g, Theme.selection.b, 0.35))
    implicitHeight: layout.implicitHeight + 2 * contentInset

    function widthFor(screenWidth) { return appearance.widthFor(screenWidth); }

    component ActionButton: Button {
        id: button
        required property string hotkey
        property bool compact: false
        implicitHeight: compact ? 36 : 68
        horizontalPadding: compact ? 10 : 16
        verticalPadding: compact ? 6 : 14
        focusPolicy: Qt.NoFocus
        hoverEnabled: true
        background: Rectangle {
            radius: Theme.cornerRadius
            color: button.down ? Theme.selection : surface.buttonColor
            border.width: 1
            border.color: button.enabled && button.hovered ? Theme.accent : Theme.selection
        }
        contentItem: RowLayout {
            spacing: button.compact ? 8 : 14
            opacity: button.enabled ? 1 : 0.5
            Rectangle {
                Layout.preferredWidth: button.compact ? 22 : 32
                Layout.preferredHeight: button.compact ? 22 : 32
                radius: Theme.cornerRadius
                color: Theme.background
                border.width: 1
                border.color: Theme.selection
                Text {
                    anchors.centerIn: parent
                    text: button.hotkey
                    font.family: Theme.iconFont
                    font.pixelSize: button.compact ? Theme.fontSize : 16
                    color: button.compact ? Theme.muted : Theme.accent
                }
            }
            Text {
                text: button.text
                font.family: Theme.uiFont
                font.pixelSize: button.compact ? Theme.fontSize : 16
                color: Theme.foreground
                elide: Text.ElideRight
                Layout.minimumWidth: 0
                Layout.fillWidth: true
            }
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: surface.contentInset
        spacing: 18
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "Controls"
                color: Theme.foreground
                font.family: Theme.uiFont
                font.pixelSize: 20
                Layout.fillWidth: true
            }
            ActionButton {
                objectName: "controlsClose"
                text: "Close"
                hotkey: "q"
                compact: true
                onClicked: surface.closeRequested()
            }
        }
        GridLayout {
            Layout.fillWidth: true
            columns: surface.width >= 560 ? 2 : 1
            uniformCellWidths: true
            columnSpacing: 12
            rowSpacing: 10
            Repeater {
                model: surface.actions
                ActionButton {
                    required property var modelData
                    objectName: "controlsAction_" + modelData.key
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    hotkey: modelData.key
                    text: modelData.label
                    enabled: surface.actionsEnabled
                    onClicked: surface.actionRequested(modelData.key)
                }
            }
        }
        MenuError {
            Layout.fillWidth: true
            text: surface.errorMessage
        }
    }
}
