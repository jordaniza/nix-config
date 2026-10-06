import QtQuick
import "../../theme"

ControlsSurface {
    signal dismissed()
    signal activated(string key)
    focus: true
    onCloseRequested: dismissed()
    onActionRequested: key => activate(key)

    function activate(key) {
        if (actionsEnabled && actions.some(action => action.key === key))
            activated(key);
    }

    function handleKey(event) {
        const modified = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier);
        if (!modified && !event.isAutoRepeat) {
            if (event.key === Qt.Key_Q || event.key === Qt.Key_Escape)
                dismissed();
            else
                activate(event.text.toLowerCase());
        }
        event.accepted = true;
    }
    Keys.onPressed: event => handleKey(event)
}
