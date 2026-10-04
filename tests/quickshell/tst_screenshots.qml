import QtQuick
import QtTest
import "../../config/quickshell/components/screenshots"

TestCase {
    id: test
    name: "Screenshots"
    when: windowShown
    width: 400
    height: 400

    QtObject {
        id: fakeProcess
        property var command: []
        property bool running: false
        property int requests: 0
        signal started()
        signal exited(int exitCode, int exitStatus)
        onRunningChanged: if (running) requests++
        function finish(code, status) {
            exited(code, status);
            running = false;
        }
    }
    ScreenshotController {
        id: controller
        command: "/fake/screenshot-copy"
        process: fakeProcess
    }
    ScreenshotList {
        id: list
        width: 380
        height: 400
        folder: Qt.resolvedUrl("fixtures")
        actionsEnabled: !controller.pending
        onActivated: path => controller.copy(path)
    }
    SignalSpy { id: copied; target: controller; signalName: "copied" }
    SignalSpy { id: dismissed; target: list; signalName: "dismissed" }

    function init() {
        controller.runner.state = "idle";
        fakeProcess.running = false;
        fakeProcess.requests = 0;
        controller.errorMessage = "";
        controller.command = "/fake/screenshot-copy";
        list.folder = Qt.resolvedUrl("fixtures");
        tryCompare(list, "count", 40);
        list.currentIndex = 0;
        list.positionViewAtBeginning();
        list.forceActiveFocus();
        copied.clear(); dismissed.clear();
    }

    function test_newestFirstAndLazyRows() {
        compare(list.model.get(0, "fileName"), "newest # &.png");
        verify(list.model.get(0, "fileModified") > list.model.get(1, "fileModified"));
        verify(list.itemAtIndex(35) === null);
    }

    function test_navigationCopyAndDuplicateEnter() {
        keyClick(Qt.Key_K);
        compare(list.currentIndex, 0);
        keyClick(Qt.Key_J);
        compare(list.currentIndex, 1);
        keyClick(Qt.Key_Return);
        compare(fakeProcess.command[0], "/fake/screenshot-copy");
        compare(fakeProcess.command[1], list.model.get(1, "filePath"));
        compare(fakeProcess.requests, 1);
        keyClick(Qt.Key_Return);
        compare(fakeProcess.requests, 1);
        fakeProcess.started();
        compare(copied.count, 0);
        fakeProcess.finish(0, 0);
        compare(copied.count, 1);
    }

    function test_longListScrollAndDismiss() {
        for (let i = 0; i < 45; ++i)
            keyClick(Qt.Key_J);
        compare(list.currentIndex, 39);
        verify(list.contentY > 0);
        keyClick(Qt.Key_Q);
        keyClick(Qt.Key_Escape);
        compare(dismissed.count, 2);
        compare(fakeProcess.requests, 0);
    }

    function test_failureKeepsSelectionAndAllowsRetry() {
        list.currentIndex = 3;
        keyClick(Qt.Key_Return);
        fakeProcess.started();
        fakeProcess.finish(1, 0);
        compare(copied.count, 0);
        compare(list.currentIndex, 3);
        verify(controller.errorMessage.length > 0);
        keyClick(Qt.Key_Return);
        fakeProcess.started();
        fakeProcess.finish(0, 0);
        compare(copied.count, 1);
        compare(controller.errorMessage, "");
    }

    function test_failedStartAndMissingCommand() {
        controller.copy("/fake/capture.png");
        fakeProcess.running = false;
        verify(!controller.pending);
        verify(controller.errorMessage.length > 0);
        compare(copied.count, 0);
        controller.command = "";
        controller.copy("/fake/capture.png");
        compare(fakeProcess.requests, 1);
    }

    function test_emptyFolderDoesNotCopy() {
        list.folder = Qt.resolvedUrl("empty-fixtures");
        tryCompare(list, "count", 0);
        keyClick(Qt.Key_Return);
        compare(fakeProcess.requests, 0);
        keyClick(Qt.Key_Escape);
        compare(dismissed.count, 1);
    }
}
