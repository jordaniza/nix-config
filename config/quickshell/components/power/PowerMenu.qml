import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../shared"
import "../../theme"

PopupWindow {
    id: menu
    required property string actionCommand
    preferredWidth: appearance.preferredWidth
    focusTarget: list
    WlrLayershell.namespace: "power"
    onOpened: list.currentIndex = 0

    property PowerAppearance appearance: PowerAppearance {}
    property PowerController controller: PowerController {
        command: menu.actionCommand
        process: Process {
            stderr: SplitParser {
                onRead: data => console.error("[power]", data)
            }
        }
        onDispatched: menu.close()
        onFailed: menu.open()
    }

    Column {
        width: parent.width
        spacing: appearance.contentSpacing
        ActionList {
            id: list
            width: parent.width
            height: implicitHeight
            model: menu.controller.actions
            icons: Icons
            actionsEnabled: !menu.controller.pending
            onActivated: key => menu.controller.execute(key)
            onDismissed: menu.close()
            onRejected: message => {
                console.error(message);
                menu.controller.errorMessage = message;
            }
        }
        MenuError {
            width: parent.width
            text: menu.controller.errorMessage
        }
    }
}
