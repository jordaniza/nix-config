import QtQuick
import QtTest
import "../../config/quickshell/components/power"
import "../../config/quickshell/shared"
import "../../config/quickshell/shared/VimNavigation.js" as Navigation
import "../../config/theme/quickshell"

TestCase {
    id: test
    name: "PowerMenu"
    when: windowShown
    width: 240
    height: 300

    QtObject {
        id: fakeProcess
        property var command: []
        property bool running: false
        property int requests: 0
        signal started()
        signal exited(int exitCode, int exitStatus)
        onRunningChanged: if (running) requests++
        function finish(code, status) {
            // Match Quickshell: exited is emitted before runningChanged.
            exited(code, status);
            running = false;
        }
    }
    PowerController {
        id: power
        command: "/fake/power-action"
        process: fakeProcess
    }
    ActionList {
        id: list
        width: 200
        height: implicitHeight
        model: power.actions
        actionsEnabled: !power.pending
        onActivated: key => power.execute(key)
    }
    SignalSpy { id: dismissal; target: list; signalName: "dismissed" }
    SignalSpy { id: rejection; target: list; signalName: "rejected" }
    SignalSpy { id: failure; target: power; signalName: "failed" }
    SignalSpy { id: dispatch; target: power; signalName: "dispatched" }
    MenuRow { id: row; glyph: ""; text: "Lock"; visible: false }
    MenuSurface {
        id: surface
        visible: false
        width: 200
        Item { implicitHeight: 120 }
    }

    function init() {
        power.runner.state = "idle";
        fakeProcess.running = false;
        fakeProcess.requests = 0;
        power.command = "/fake/power-action";
        power.errorMessage = "";
        list.editing = false;
        list.currentIndex = 0;
        list.forceActiveFocus();
        dismissal.clear(); rejection.clear(); failure.clear(); dispatch.clear();
    }

    function test_navigationAndDispatch() {
        keyClick(Qt.Key_J);
        compare(list.currentIndex, 1);
        keyClick(Qt.Key_Tab);
        compare(list.currentIndex, 2);
        keyClick(Qt.Key_Return);
        compare(fakeProcess.command[1], "restart");
        compare(fakeProcess.requests, 1);
        verify(power.pending);
        keyClick(Qt.Key_Return);
        compare(fakeProcess.requests, 1);
        fakeProcess.started();
        compare(dispatch.count, 1);
        fakeProcess.finish(0, 0);
        verify(!power.pending);
    }

    function test_dismissWhilePending() {
        power.execute("lock");
        keyClick(Qt.Key_Q);
        keyClick(Qt.Key_Escape);
        compare(dismissal.count, 2);
        compare(fakeProcess.requests, 1);
    }

    function test_navigationBoundariesAndEditing() {
        keyClick(Qt.Key_K);
        compare(list.currentIndex, 3);
        keyClick(Qt.Key_Tab, Qt.ShiftModifier);
        compare(list.currentIndex, 2);
        list.editing = true;
        keyClick(Qt.Key_J);
        keyClick(Qt.Key_Q);
        compare(list.currentIndex, 2);
        compare(dismissal.count, 0);
        compare(Navigation.move(-1, 0, 1, true), -1);
        compare(Navigation.move(3, 4, 1, false), 3);
    }

    function test_autoRepeatAndModifiers() {
        compare(Navigation.intent({key: Qt.Key_Return, modifiers: 0, isAutoRepeat: true}, Qt, false), "consume");
        compare(Navigation.intent({key: Qt.Key_J, modifiers: Qt.ControlModifier, isAutoRepeat: false}, Qt, false), "");
    }

    function test_failedStartAndRecovery() {
        power.execute("shutdown");
        fakeProcess.running = false;
        verify(!power.pending);
        compare(failure.count, 1);
        verify(power.errorMessage.length > 0);
        power.execute("lock");
        compare(fakeProcess.requests, 2);
        fakeProcess.started();
        fakeProcess.finish(0, 0);
        compare(power.errorMessage, "");
    }

    function test_nonzeroAndCrash() {
        power.execute("suspend");
        fakeProcess.started();
        fakeProcess.finish(1, 0);
        compare(power.errorMessage, "Suspend failed.");
        verify(!power.pending);
        power.execute("restart");
        fakeProcess.started();
        fakeProcess.finish(0, 1);
        compare(failure.count, 2);
    }

    function test_invalidInputsDoNotExecute() {
        power.execute("hibernate");
        verify(power.errorMessage.length > 0);
        list.activate(-1);
        list.activate(0.5);
        compare(rejection.count, 2);
        compare(fakeProcess.requests, 0);
        power.command = "";
        power.execute("lock");
        compare(fakeProcess.requests, 0);
        compare(power.errorMessage, "Power command unavailable.");
    }

    function test_eachActionAndRowSizing() {
        for (const key of ["lock", "suspend", "restart", "shutdown"]) {
            power.execute(key);
            compare(fakeProcess.command[0], "/fake/power-action");
            compare(fakeProcess.command[1], key);
            fakeProcess.started();
            fakeProcess.finish(0, 0);
        }
        verify(row.implicitHeight >= row.implicitContentHeight + row.topPadding + row.bottomPadding);
        verify(row.implicitHeight >= row.minimumHeight);
        const oldHeight = row.implicitHeight;
        row.contentItem.children[1].font.pixelSize = 32;
        tryVerify(() => row.implicitHeight > oldHeight);
        compare(surface.implicitHeight, 120 + surface.topPadding + surface.bottomPadding);
    }
}
