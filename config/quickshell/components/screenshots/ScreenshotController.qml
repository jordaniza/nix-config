import QtQml
import "../../shared"

QtObject {
    id: controller
    required property QtObject process
    required property string command
    readonly property bool pending: runner.pending
    property string errorMessage: ""
    signal copied()

    function copy(path) {
        if (pending || !path)
            return;
        errorMessage = "";
        if (!command) {
            errorMessage = "Copy command unavailable.";
            return;
        }
        runner.run([command, path]);
    }

    property CommandRunner runner: CommandRunner {
        process: controller.process
        onFinished: (exitCode, exitStatus) => {
            if (exitCode === 0 && exitStatus === 0)
                controller.copied();
            else
                controller.errorMessage = "Could not copy screenshot.";
        }
        onFailedToStart: controller.errorMessage = "Copy command could not start."
    }
}
