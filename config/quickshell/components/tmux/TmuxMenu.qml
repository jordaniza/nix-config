import QtQuick
import Quickshell.Io
import Quickshell.Wayland
import "../../shared"
import "../../theme"

PopupWindow {
    id: menu
    required property string tmuxExecutable
    property TmuxAppearance appearance: TmuxAppearance {}
    preferredWidth: appearance.preferredWidth
    focusTarget: list
    WlrLayershell.namespace: "tmux"
    onOpened: {
        controller.refresh();
        list.positionViewAtBeginning();
    }

    property TmuxController controller: TmuxController {
        tmuxExecutable: menu.tmuxExecutable
        output: stdout.text
        diagnostic: stderr.text
        process: Process {
            environment: ({LC_ALL: "C", TMUX: null})
            stdout: StdioCollector { id: stdout }
            stderr: StdioCollector { id: stderr }
        }
    }
    TmuxList {
        id: list
        width: parent.width
        height: implicitHeight
        model: controller.sessions
        sampledAt: controller.sampledAt
        message: controller.pending ? "Loading…" : controller.errorMessage || "No sessions"
        onDismissed: menu.close()
    }
}
