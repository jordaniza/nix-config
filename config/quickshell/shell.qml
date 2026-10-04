import QtQml
import Quickshell
import Quickshell.Io
import "components/power"
import "components/screenshots"

ShellRoot {
    id: shell
    readonly property QtObject startup: QtObject {
        readonly property string powerAction: Quickshell.env("POWER_ACTION")
        readonly property string screenshotCopy: Quickshell.env("SCREENSHOT_COPY")
        readonly property string screenshotDirectory: Quickshell.env("SCREENSHOT_DIRECTORY")
        readonly property url screenshotFolder: "file://" + encodeURIComponent(screenshotDirectory).replace(/%2F/g, "/")
    }

    PowerMenu {
        id: powerMenu
        actionCommand: shell.startup.powerAction
        onVisibleChanged: Quickshell.execDetached(["power-menu-status", "--refresh"])
    }

    ScreenshotHistory {
        id: screenshots
        copyCommand: shell.startup.screenshotCopy
        folder: shell.startup.screenshotFolder
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
