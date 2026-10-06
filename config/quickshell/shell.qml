import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "shared"
import "shared/ShellCommand.js" as ShellCommand
import "components/power"
import "components/screenshots"
import "components/tmux"
import "components/controls"

ShellRoot {
    id: shell
    StartupConfig {
        id: startup
        path: Qt.resolvedUrl("config.json")
    }

    PowerMenu {
        id: powerMenu
        actionCommand: startup.powerAction
        onVisibleChanged: Quickshell.execDetached(["power-menu-status", "--refresh"])
    }

    ScreenshotHistory {
        id: screenshots
        copyCommand: startup.screenshotCopy
        folder: startup.screenshotFolder
    }

    TmuxMenu {
        id: tmuxMenu
        tmuxExecutable: startup.tmux
        onVisibleChanged: Quickshell.execDetached(["tmux-status", "--refresh"])
    }

    MenuCoordinator {
        id: coordinator
        menus: ({power: powerMenu, screenshots: screenshots, tmux: tmuxMenu, controls: controls})
    }

    ControlsController {
        id: controlsController
        coordinator: coordinator
        actions: startup.controlsActions
        // Release exclusive focus before asking the terminal to open.
        launch: argv => {
            controls.close();
            try {
                Hyprland.dispatch("exec " + ShellCommand.fromArgv(argv));
            } catch (error) {
                coordinator.open("controls");
                throw error;
            }
        }
    }

    ControlsMenu { id: controls; controller: controlsController }

    IpcHandler {
        target: "controls"
        function open(): bool {
            return coordinator.open("controls");
        }
    }

    IpcHandler {
        target: "tmux"
        readonly property bool visible: tmuxMenu.visible
        function open(): bool {
            return coordinator.open("tmux");
        }
    }

    IpcHandler {
        target: "screenshots"
        function open(): bool {
            return coordinator.open("screenshots");
        }
    }

    IpcHandler {
        target: "power"
        readonly property bool visible: powerMenu.visible
        function open(): bool {
            return coordinator.open("power");
        }
    }
}
