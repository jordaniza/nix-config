import QtQml
import "../../shared"
import "TmuxData.js" as Data

QtObject {
    id: controller
    required property string tmuxExecutable
    required property QtObject process
    property string output: ""
    property string diagnostic: ""
    property var sessions: []
    property double sampledAt: 0
    property string errorMessage: ""
    readonly property bool pending: runner.pending

    function refresh() {
        if (pending) return;
        sessions = [];
        errorMessage = "";
        // Query only the default local server; -N never starts a server.
        runner.run([tmuxExecutable, "-N", "-u", "-L", "default", "list-windows", "-a", "-F", Data.format]);
    }

    property CommandRunner runner: CommandRunner {
        process: controller.process
        onFailedToStart: controller.errorMessage = "Could not read tmux sessions."
        onFinished: (exitCode, exitStatus) => {
            if (exitStatus === 0 && exitCode === 0) {
                try {
                    controller.sessions = Data.parse(controller.output);
                    controller.sampledAt = Date.now() / 1000;
                } catch (error) {
                    controller.errorMessage = "Could not read tmux sessions.";
                }
            } else if (exitStatus !== 0 || !Data.noServer(controller.diagnostic)) {
                controller.errorMessage = "Could not read tmux sessions.";
            }
        }
    }
    // Bound a stalled query without a shell or a second tmux client.
    property Timer deadline: Timer {
        interval: 3000
        running: controller.runner.state === "running"
        onTriggered: controller.process.signal(9)
    }
}
