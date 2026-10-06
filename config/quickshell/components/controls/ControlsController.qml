import QtQml

QtObject {
    id: controller
    required property QtObject coordinator
    required property var actions
    required property var launch
    property bool busy: false
    property string errorMessage: ""
    signal dispatched()

    function reset() {
        busy = false;
        errorMessage = "";
    }

    function activate(key) {
        if (busy)
            return;
        const action = actions.find(candidate => candidate.key === key);
        const target = action?.menu;
        const command = action?.command;
        if (!target && (!Array.isArray(command) || command.length === 0
                || command.some(argument => typeof argument !== "string" || argument.length === 0))) {
            errorMessage = "Command unavailable.";
            return;
        }
        busy = true;
        errorMessage = "";
        try {
            if (target && !coordinator.open(target)) {
                busy = false;
                errorMessage = "Menu could not open.";
                return;
            }
            if (!target)
                launch(command);
            dispatched();
        } catch (error) {
            busy = false;
            errorMessage = "Command could not launch.";
            console.error("[controls]", error);
        }
    }
}
