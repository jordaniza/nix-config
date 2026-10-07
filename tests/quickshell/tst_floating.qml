import QtQuick
import Quickshell
import "shared"
import "components/controls"
import "components/tmux"

ShellRoot {
    id: root
    property int opens: 0
    property var commands: []
    FloatingMenuWindow {
        id: menu
        title: "Quickshell test"
        preferredWidth: 640
        focusTarget: content
        focusedMonitorName: () => Quickshell.screens[0]?.name
        dispatch: command => root.commands = root.commands.concat([command])
        onOpened: root.opens++
        ControlsContent {
            id: content
            width: parent.width
            actions: [{key: "t", label: "tmux"}]
            onDismissed: menu.close()
        }
    }
    property MenuCoordinator coordinator: MenuCoordinator { menus: ({}) }
    property ControlsController controller: ControlsController {
        coordinator: root.coordinator
        actions: []
        launch: argv => Qt.exit(7)
    }
    ControlsMenu { controller: root.controller; dispatch: command => Qt.exit(8) }
    TmuxMenu { tmuxExecutable: "/nonexistent-test-tmux"; dispatch: command => Qt.exit(9) }
    Timer {
        interval: 50
        running: true
        property int step: 0
        repeat: true
        onTriggered: {
            if (step === 0) {
                if (!menu.open()) Qt.exit(1);
            } else if (step === 1) {
                if (!menu.visible || !menu.backingWindowVisible || root.opens !== 1
                        || root.commands.length !== 1
                        || root.commands[0] !== "focuswindow title:^(Quickshell test)$"
                        || menu.minimumSize.width !== menu.implicitWidth
                        || menu.maximumSize.height !== menu.implicitHeight)
                    Qt.exit(2);
                content.focus = false;
            } else if (step === 2) {
                if (!menu.visible) Qt.exit(3);
                menu.open();
                if (root.opens !== 1 || root.commands.length !== 2) Qt.exit(4);
                menu.close();
            } else if (step === 3) {
                if (menu.visible || menu.backingWindowVisible) Qt.exit(5);
                menu.open();
            } else {
                if (!menu.visible || root.opens !== 2 || root.commands.length !== 3) Qt.exit(6);
                menu.close();
                console.log("FLOATING_MENU_OK");
                Qt.quit();
            }
            step++;
        }
    }
}
