import QtQml
import Quickshell
import Quickshell.Io
import "shared"
import "components/power"
import "components/screenshots"

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

    IpcHandler {
        target: "screenshots"
        function open(): bool {
            powerMenu.close();
            return screenshots.open();
        }
    }

    IpcHandler {
        target: "power"
        readonly property bool visible: powerMenu.visible
        function open(): bool {
            screenshots.close();
            return powerMenu.open();
        }
    }
}
