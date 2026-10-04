import QtQml

QtObject {
    id: runner
    // Inject Quickshell's Process in production; tests supply a fake.
    required property QtObject process
    readonly property bool pending: state !== "idle"
    property string state: "idle"
    signal started()
    signal finished(int exitCode, int exitStatus)
    signal failedToStart()

    function run(argv) {
        if (pending)
            return false;
        state = "starting";
        process.command = argv;
        process.running = true;
        return true;
    }

    property Connections lifecycle: Connections {
        target: runner.process
        function onStarted() {
            runner.state = "running";
            runner.started();
        }
        function onExited(exitCode, exitStatus) {
            runner.state = "idle";
            runner.finished(exitCode, exitStatus);
        }
        function onRunningChanged() {
            // Quickshell 0.3.0 does not emit exited when startup fails.
            if (!runner.process.running && runner.state === "starting") {
                runner.state = "idle";
                runner.failedToStart();
            }
        }
    }
}
