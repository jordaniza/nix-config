import QtQuick
import Quickshell.Io
import "../../shared"
import "../../theme"

FloatingMenuWindow {
    id: menu
    required property string tmuxExecutable
    property TmuxAppearance appearance: TmuxAppearance {}
    title: "Quickshell tmux"
    preferredWidth: appearance.widthFor(screen?.width ?? 0)
    implicitHeight: Math.min(appearance.preferredHeight,
        Math.max(1, (screen?.height ?? Infinity) - 2 * appearance.screenInset))
    focusTarget: list
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
        height: parent.height
        model: controller.sessions
        sampledAt: controller.sampledAt
        message: controller.pending ? "Loading…" : controller.errorMessage || "No sessions"
        onDismissed: menu.close()
    }
}
