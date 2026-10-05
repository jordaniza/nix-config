pragma ComponentBehavior: Bound
import QtQuick
import "../../theme"
import "../../shared/VimNavigation.js" as Navigation
import "TmuxData.js" as Data

ListView {
    id: list
    property double sampledAt: 0
    property string message: ""
    signal dismissed()
    property TmuxAppearance appearance: TmuxAppearance {}
    implicitHeight: count ? Math.min(contentHeight, appearance.maximumHeight) : appearance.emptyHeight
    clip: true
    keyNavigationEnabled: false
    boundsBehavior: Flickable.StopAtBounds
    spacing: appearance.sessionSpacing
    delegate: TmuxSessionRow {
        required property var modelData
        width: list.width
        session: modelData
        age: Data.age(modelData.created, list.sampledAt)
    }
    ListMessage {
        anchors.centerIn: parent
        width: parent.width
        visible: list.count === 0
        text: list.message
    }
    Keys.onPressed: event => {
        const intent = Navigation.intent(event, Qt, false);
        if (intent === "dismiss") {
            list.dismissed();
        } else if (intent === "next" || intent === "previous") {
            const delta = intent === "next" ? appearance.scrollStep : -appearance.scrollStep;
            contentY = Math.max(originY, Math.min(originY + Math.max(0, contentHeight - height), contentY + delta));
        } else {
            return;
        }
        event.accepted = true;
    }
}
