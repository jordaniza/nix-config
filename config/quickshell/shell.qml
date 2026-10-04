import Quickshell
import Quickshell.Io
import "components/power"

ShellRoot {
    PowerMenu {
        id: powerMenu
        onVisibleChanged: Quickshell.execDetached(["power-menu-status", "--refresh"])
    }

    IpcHandler {
        target: "power"
        readonly property bool visible: powerMenu.visible
        function open(): bool { return powerMenu.open(); }
    }
}
