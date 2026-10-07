pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../../theme"
import "../../shared/VimNavigation.js" as Navigation
import "TmuxData.js" as Data

TmuxSurface {
    id: board
    property var model: []
    property double sampledAt: 0
    property string message: ""
    readonly property alias view: list
    summary: model.length + (model.length === 1 ? " session" : " sessions")
        + " · " + model.filter(session => session.attached).length + " attached"
    focus: true
    signal dismissed()
    onCloseRequested: dismissed()

    function positionViewAtBeginning() { list.positionViewAtBeginning(); }

    ListView {
        id: list
        anchors.fill: parent
        readonly property int columns: board.appearance.columnsFor(width, board.model.length)
        model: Data.boardRows(board.model, columns)
        clip: true
        keyNavigationEnabled: false
        boundsBehavior: Flickable.StopAtBounds
        spacing: board.appearance.sessionSpacing
        delegate: TmuxSessionGroup {
            required property var modelData
            width: list.width
            height: implicitHeight
            minimumHeight: list.height
            columns: list.columns
            sessions: modelData
            ages: modelData.map(session => Data.age(session.created, board.sampledAt))
        }
        ListMessage {
            objectName: "tmuxMessage"
            anchors.centerIn: parent
            width: parent.width
            visible: board.model.length === 0
            text: board.message
        }
    }
    Keys.onPressed: event => {
        const intent = Navigation.intent(event, Qt, false);
        if (intent === "dismiss") {
            board.dismissed();
        } else if (intent === "next" || intent === "previous") {
            const delta = intent === "next" ? appearance.scrollStep : -appearance.scrollStep;
            list.contentY = Math.max(list.originY, Math.min(list.originY
                + Math.max(0, list.contentHeight - list.height), list.contentY + delta));
        } else {
            return;
        }
        event.accepted = true;
    }
}
