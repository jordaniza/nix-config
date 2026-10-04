pragma ComponentBehavior: Bound
import QtQuick
import "../theme"
import "VimNavigation.js" as Navigation

ListView {
    id: list
    property var icons: ({})
    property var keyAtIndex: index => model[index].key
    property bool actionsEnabled: true
    property bool editing: false
    property bool wrapNavigation: true
    signal activated(string key)
    signal dismissed()
    signal rejected(string message)

    implicitHeight: contentHeight
    interactive: false
    keyNavigationEnabled: false
    focus: true
    clip: true

    function activate(index) {
        if (!Number.isInteger(index) || index < 0 || index >= count) {
            rejected("Invalid action selection.");
            return;
        }
        if (actionsEnabled)
            activated(keyAtIndex(index));
    }

    Keys.onPressed: event => {
        const action = Navigation.intent(event, Qt, editing);
        if (!action)
            return;
        if (action === "next" || action === "previous") {
            currentIndex = Navigation.move(currentIndex, count, action === "next" ? 1 : -1, wrapNavigation);
            if (currentIndex >= 0)
                positionViewAtIndex(currentIndex, ListView.Contain);
        } else if (action === "activate") {
            activate(currentIndex);
        } else if (action === "dismiss") {
            dismissed();
        }
        event.accepted = true;
    }

    delegate: MenuRow {
        required property int index
        required property var modelData
        width: list.width
        text: modelData.label
        glyph: list.icons[modelData.key] ?? ""
        selected: list.currentIndex === index
        enabled: list.actionsEnabled
        onClicked: list.activate(index)
    }
}
