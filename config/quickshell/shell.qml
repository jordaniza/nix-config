import QtQml
import Quickshell
import Quickshell.Io
import "shared"
import "components/power"
import "components/screenshots"
import "components/tmux"

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

    IpcHandler {
        target: "tmux"
        readonly property bool visible: tmuxMenu.visible
        function open(): bool {
            powerMenu.close();
            screenshots.close();
            return tmuxMenu.open();
        }
    }

    IpcHandler {
        target: "screenshots"
        function open(): bool {
            powerMenu.close();
            tmuxMenu.close();
            return screenshots.open();
        }
    }

    IpcHandler {
        target: "power"
        readonly property bool visible: powerMenu.visible
        function open(): bool {
            screenshots.close();
            tmuxMenu.close();
            return powerMenu.open();
        }
    }
}
