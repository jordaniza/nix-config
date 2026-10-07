import QtQuick
import QtTest
import "../../config/quickshell/components/tmux"
import "../../config/quickshell/components/tmux/TmuxData.js" as Data

TestCase {
    name: "TmuxViewer"
    when: windowShown
    width: 340
    height: 200
    visible: true
    QtObject {
        id: process
        property var command: []
        property bool running: false
        property int requests: 0
        signal started()
        signal exited(int exitCode, int exitStatus)
        onRunningChanged: if (running) requests++
        function finish(code, status) { exited(code, status); running = false; }
        function signal(number) { finish(0, 1); }
    }
    TmuxController { id: controller; tmuxExecutable: "/fake bin/tmux"; process: process }
    TmuxList {
        id: list
        width: 320
        height: 120
        model: controller.sessions
        sampledAt: controller.sampledAt
    }
    SignalSpy { id: dismissal; target: list; signalName: "dismissed" }

    function init() {
        controller.runner.state = "idle";
        process.running = false;
        process.requests = 0;
        controller.sessions = [];
        controller.errorMessage = "";
        controller.output = "";
        controller.diagnostic = "";
        dismissal.clear();
        list.forceActiveFocus();
    }

    function test_groupingOrderAndLiteralNames() {
        const sessions = Data.parse("$2\t100\t0\t9\tlogs\n$1\t200\t3\t2\t<b>猫</b> # \\\"\n$1\t200\t3\t0\teditor\n");
        compare(sessions.length, 2);
        verify(sessions[0].attached);
        compare(sessions[0].windows.length, 2);
        compare(sessions[0].windows[0].name, "editor");
        compare(sessions[0].windows[1].name, "<b>猫</b> # \\\"");
        verify(!sessions[1].attached);
        compare(Data.parse("").length, 0);
    }

    function test_queryAndRefresh() {
        controller.refresh();
        controller.refresh();
        compare(process.requests, 1);
        compare(process.command, ["/fake bin/tmux", "-N", "-u", "-L", "default", "list-windows", "-a", "-F", Data.format]);
        process.started();
        controller.output = "$1\t100\t1\t0\teditor\n";
        process.finish(0, 0);
        compare(controller.sessions.length, 1);
        verify(controller.sampledAt > 100);
        controller.refresh();
        compare(controller.sessions.length, 0);
        compare(process.requests, 2);
        process.started();
        controller.output = "$2\t200\t0\t0\tshell\n";
        process.finish(0, 0);
        compare(controller.sessions[0].windows[0].name, "shell");
    }

    function test_failuresAndEmptyServer() {
        for (const diagnostic of ["no server running on /synthetic/default\n", "error connecting to /synthetic/default (No such file or directory)\n", "permission denied"]) {
            controller.refresh(); process.started();
            controller.diagnostic = diagnostic;
            process.finish(1, 0);
            compare(controller.errorMessage.length > 0, diagnostic === "permission denied");
            compare(controller.sessions.length, 0);
        }
        controller.refresh();
        process.running = false;
        verify(controller.errorMessage.length > 0);
        controller.refresh(); process.started();
        controller.output = "malformed";
        process.finish(0, 0);
        verify(controller.errorMessage.length > 0);
        controller.refresh(); process.started();
        process.finish(0, 1);
        verify(controller.errorMessage.length > 0);
    }

    function test_deadline() {
        controller.deadline.interval = 20;
        controller.refresh(); process.started();
        tryVerify(() => !controller.pending);
        verify(controller.errorMessage.length > 0);
        controller.deadline.interval = 3000;
    }

    function test_readOnlyScrollAndDismiss() {
        controller.sessions = Data.parse(Array.from({length: 15}, (_, i) => "$1\t100\t1\t" + i + "\twindow " + i).join("\n"));
        tryVerify(() => list.view.contentHeight > list.height);
        verify(list.activeFocus);
        list.positionViewAtBeginning();
        const beginning = list.view.contentY;
        keyClick(Qt.Key_J);
        verify(list.view.contentY > beginning);
        keyClick(Qt.Key_K);
        compare(list.view.contentY, beginning);
        keyClick(Qt.Key_Return);
        compare(process.requests, 0);
        verify(!list.view.highlight);
        keyClick(Qt.Key_Q);
        keyClick(Qt.Key_Escape);
        compare(dismissal.count, 2);
    }

    function test_boardColumnsAndRows() {
        const sessions = Array.from({length: 7}, (_, index) => ({id: "$" + index, windows: []}));
        compare(Data.boardRows(sessions, 3).map(row => row.length), [3, 3, 1]);
        compare(list.appearance.columnsFor(900, 1), 1);
        compare(list.appearance.columnsFor(900, 7), 3);
        compare(list.appearance.columnsFor(650, 7), 2);
        compare(list.appearance.columnsFor(450, 7), 1);
    }

    function test_cardAndMouseClose() {
        list.width = 960; list.height = 400;
        controller.sessions = Data.parse("$1\t100\t1\t0\t<b>literal</b>\n");
        tryVerify(() => findChild(list, "tmuxSession_$1") !== null);
        const card = findChild(list, "tmuxSession_$1");
        const name = findChild(card, "windowName");
        compare(name.text, "<b>literal</b>");
        compare(name.textFormat, Text.PlainText);
        verify(card.width > 800);
        mouseClick(findChild(list, "tmuxClose"));
        compare(dismissal.count, 1);
        list.width = 320; list.height = 120;
    }

    function test_ages() {
        compare(Data.age(100, 99), "<1m");
        compare(Data.age(100, 160), "1m");
        compare(Data.age(100, 7300), "2h");
        compare(Data.age(100, 259300), "3d");
    }
}
