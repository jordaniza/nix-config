pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Item {
    id: group
    required property var sessions
    required property var ages
    required property int columns
    property int minimumHeight: 0
    property TmuxAppearance appearance: TmuxAppearance {}
    implicitHeight: Math.max(minimumHeight, ...sessions.map(session => appearance.cardHeightFor(session.windows.length)))
    RowLayout {
        anchors.fill: parent
        spacing: group.appearance.sessionSpacing
        Repeater {
            model: group.sessions
            TmuxSessionRow {
                required property var modelData
                required property int index
                objectName: "tmuxSession_" + modelData.id
                Layout.preferredWidth: (group.width - (group.columns - 1) * group.appearance.sessionSpacing) / group.columns
                Layout.minimumWidth: 0
                Layout.fillHeight: true
                session: modelData
                age: group.ages[index]
            }
        }
        Item {
            visible: group.sessions.length < group.columns
            Layout.fillWidth: true
            Layout.preferredWidth: (group.columns - group.sessions.length)
                * (group.width - (group.columns - 1) * group.appearance.sessionSpacing) / group.columns
                + Math.max(0, group.columns - group.sessions.length - 1) * group.appearance.sessionSpacing
        }
    }
}
