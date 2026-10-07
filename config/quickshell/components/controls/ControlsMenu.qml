import QtQuick
import "../../shared"

FloatingMenuWindow {
    id: menu
    required property ControlsController controller
    title: "Quickshell Controls"
    preferredWidth: content.widthFor(screen?.width ?? 0)
    focusTarget: content
    onOpened: controller.reset()

    property Connections dispatch: Connections {
        target: menu.controller
        function onDispatched() { menu.close(); }
    }

    ControlsContent {
        id: content
        width: parent.width
        actions: menu.controller.actions
        actionsEnabled: !menu.controller.busy
        errorMessage: menu.controller.errorMessage
        onActivated: key => menu.controller.activate(key)
        onDismissed: menu.close()
    }
}
