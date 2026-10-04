import QtQml
import "../../shared"

QtObject {
    id: power
    required property QtObject process
    required property string command
    readonly property bool pending: runner.pending
    property string errorMessage: ""
    property string actionLabel: ""
    readonly property var actions: [
        { key: "lock", label: "Lock" },
        { key: "suspend", label: "Suspend" },
        { key: "restart", label: "Restart" },
        { key: "shutdown", label: "Shutdown" }
    ]
    signal dispatched()
    signal failed()

    function execute(key) {
        const action = actions.find(action => action.key === key);
        if (!action) {
            errorMessage = "Unknown power action.";
            console.error(errorMessage, key);
            return;
        }
        if (pending)
            return;
        if (!command) {
            errorMessage = "Power command unavailable.";
            console.error(errorMessage);
            return;
        }
        actionLabel = action.label;
        errorMessage = "";
        // TODO: cancellable restart/shutdown countdown with a Run now action.
        runner.run([command, key]);
    }

    property CommandRunner runner: CommandRunner {
        process: power.process
        onStarted: power.dispatched()
        onFinished: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                power.errorMessage = power.actionLabel + " failed.";
                console.error("[power]", power.actionLabel, "exit code", exitCode, "exit status", exitStatus);
                power.failed();
            }
        }
        onFailedToStart: {
            power.errorMessage = "Power command could not start.";
            console.error("[power]", power.errorMessage, power.command);
            power.failed();
        }
    }
}
