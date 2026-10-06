import QtQuick
import QtTest
import "../../config/quickshell/components/controls"
import "../../config/quickshell/shared"
import "../../config/quickshell/shared/ShellCommand.js" as ShellCommand

TestCase {
    name: "ControlsBox"
    when: windowShown
    visible: true
    width: 720
    height: 900
    ControlsContent { id: content; actions: controller.actions; width: 480; height: implicitHeight }
    SignalSpy { id: dismissal; target: content; signalName: "dismissed" }
    SignalSpy { id: activation; target: content; signalName: "activated" }
    QtObject {
        id: palette
        property bool visible: true
        property int opens: 0
        function open() { visible = true; opens++; return true; }
        function close() { visible = false; }
    }
    QtObject {
        id: tool
        property bool visible: false
        property bool succeeds: true
        property int opens: 0
        function open() { opens++; visible = succeeds; return succeeds; }
        function close() { visible = false; }
    }
    MenuCoordinator { id: coordinator; menus: ({controls: palette, power: tool, tmux: tool, screenshots: tool}) }
    property var launches: []
    property bool launchFails: false
    ControlsController {
        id: controller
        coordinator: coordinator
        actions: [
            {key: "p", label: "Power", menu: "power"},
            {key: "t", label: "tmux", menu: "tmux"},
            {key: "s", label: "Screenshots", menu: "screenshots"},
            {key: "c", label: "Clipboard", command: ["/fake kitty", "--title", "Clipboard history"]},
            {key: "b", label: "Bluetooth", command: ["/fake kitty", "-e", "/fake bluetuith"]},
            {key: "i", label: "Internet", command: ["/fake kitty", "-e", "/fake nmtui"]},
            {key: "v", label: "Volume", command: ["/fake kitty", "-e", "/fake pulsemixer"]}
        ]
        launch: argv => {
            if (launchFails) throw new Error("Synthetic launch failure");
            launches = launches.concat([argv]);
        }
    }
    SignalSpy { id: dispatch; target: controller; signalName: "dispatched" }

    function init() {
        dismissal.clear(); activation.clear(); dispatch.clear();
        content.width = 480;
        content.actionsEnabled = true;
        content.errorMessage = "";
        content.forceActiveFocus();
        verify(content.activeFocus);
        palette.visible = true; palette.opens = 0;
        tool.visible = false; tool.opens = 0; tool.succeeds = true;
        controller.reset(); launches = []; launchFails = false;
    }

    function test_dismissKeys() {
        keyClick(Qt.Key_Q); keyClick(Qt.Key_Escape);
        compare(dismissal.count, 2);
        compare(activation.count, 0);
    }

    function test_mouseAndKeysUseSameActions() {
        const keys = [Qt.Key_P, Qt.Key_T, Qt.Key_S, Qt.Key_C, Qt.Key_B, Qt.Key_I, Qt.Key_V];
        compare(content.actions.map(action => action.key), ["p", "t", "s", "c", "b", "i", "v"]);
        for (let index = 0; index < content.actions.length; index++) {
            const action = content.actions[index];
            keyClick(keys[index]);
            compare(activation.signalArguments[activation.count - 1][0], action.key);
            const button = findChild(content, "controlsAction_" + action.key);
            verify(button !== null);
            mouseClick(button);
            compare(activation.signalArguments[activation.count - 1][0], action.key);
        }
        compare(activation.count, 14);
    }

    function test_unassignedModifiedRepeatedAndDisabledKeys() {
        for (const key of [Qt.Key_M, Qt.Key_J, Qt.Key_K, Qt.Key_Return]) keyClick(key);
        keyClick(Qt.Key_P, Qt.ControlModifier);
        keyClick(Qt.Key_P, Qt.MetaModifier);
        const repeated = {key: Qt.Key_P, text: "p", modifiers: Qt.NoModifier, isAutoRepeat: true, accepted: false};
        content.handleKey(repeated);
        verify(repeated.accepted);
        content.actionsEnabled = false;
        keyClick(Qt.Key_P);
        mouseClick(findChild(content, "controlsAction_p"));
        compare(activation.count, 0);
        compare(dismissal.count, 0);
    }

    function test_focusAndHoverEdges() {
        const frame = findChild(content, "controlsFocusBorder");
        verify(frame !== null);
        compare(frame.border.color, content.focusBorderColor);
        compare(frame.border.width, 2);
        const button = findChild(content, "controlsAction_p");
        verify(button.height >= 68);
        compare(button.hotkey, "p");
        mouseMove(button, button.width / 2, button.height / 2);
        tryCompare(button, "hovered", true);
        compare(button.background.border.color, frame.border.color);
        content.focus = false;
        tryCompare(content, "activeFocus", false);
        compare(frame.border.width, 1);
        verify(frame.border.color !== button.background.border.color);
    }

    function test_mouseClose() {
        mouseClick(findChild(content, "controlsClose"));
        compare(dismissal.count, 1);
    }

    function test_commandDispatchAndDuplicateGuard() {
        for (const key of ["c", "b", "i", "v"]) {
            controller.reset();
            controller.activate(key); controller.activate(key);
            compare(launches[launches.length - 1], controller.actions.find(action => action.key === key).command);
        }
        compare(launches.length, 4);
        compare(dispatch.count, 4);
    }

    function test_shellQuoting() {
        compare(ShellCommand.fromArgv(["kitty", "Clipboard history", "$HOME; `whoami`"]),
            "'kitty' 'Clipboard history' '$HOME; `whoami`'");
        compare(ShellCommand.fromArgv(["a'b"]), "'a'\\''b'");
    }

    function test_popupDispatchAndCoordinator() {
        for (const key of ["p", "t", "s"]) {
            controller.reset(); palette.visible = true;
            controller.activate(key);
            verify(!palette.visible); verify(tool.visible);
        }
        compare(dispatch.count, 3); compare(tool.opens, 3);
        compare(launches.length, 0);
        coordinator.open("power");
        compare(tool.opens, 4);
        tool.close();
        coordinator.open("controls");
        verify(palette.visible); verify(!tool.visible);
        verify(!coordinator.open(null));
        verify(palette.visible);
    }

    function test_failureKeepsPaletteAndAllowsRetry() {
        tool.succeeds = false;
        controller.activate("p");
        verify(palette.visible); verify(!tool.visible);
        verify(controller.errorMessage.length > 0); verify(!controller.busy);
        compare(dispatch.count, 0);
        tool.succeeds = true;
        controller.activate("p");
        compare(dispatch.count, 1);
        controller.reset(); launchFails = true;
        controller.activate("v");
        verify(controller.errorMessage.length > 0); verify(!controller.busy);
        launchFails = false;
        controller.activate("v");
        compare(launches.length, 1);
        controller.reset(); controller.activate("m");
        verify(controller.errorMessage.length > 0);
        compare(launches.length, 1);
    }

    function test_responsiveWidth_data() {
        return [
            {tag: "wide", screen: 2560, expected: 960},
            {tag: "desktop", screen: 1920, expected: 922},
            {tag: "laptop", screen: 1366, expected: 656},
            {tag: "minimum", screen: 1000, expected: 640},
            {tag: "small", screen: 320, expected: 272}
        ];
    }

    function test_responsiveWidth(data) {
        compare(content.widthFor(data.screen), data.expected);
        content.width = data.expected;
        wait(0);
        for (const action of content.actions) {
            const button = findChild(content, "controlsAction_" + action.key);
            verify(button.width > 0);
            tryVerify(() => {
                const position = button.mapToItem(content, 0, 0);
                return position.x >= 0 && position.x + button.width <= content.width
                    && position.y >= 0 && position.y + button.height <= content.height;
            });
        }
        const first = findChild(content, "controlsAction_p");
        const second = findChild(content, "controlsAction_t");
        verify(Math.abs(first.width - second.width) <= 1);
    }
}
