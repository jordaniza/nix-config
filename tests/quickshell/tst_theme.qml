import QtQuick
import Quickshell
import "theme"
import "shared"
import "components/screenshots"
import "components/tmux"
import "components/controls"

ShellRoot {
    StartupConfig {
        id: startup
        path: Qt.resolvedUrl("config.json")
    }
    property ScreenshotAppearance screenshotAppearance: ScreenshotAppearance {}
    ScreenshotList { width: 380; height: 400; folder: Quickshell.env("TEST_SCREENSHOT_FOLDER") }
    ScreenshotRow { imageSource: ""; timestamp: "Synthetic date"; text: "capture.png" }
    ListMessage { text: "No screenshots" }
    property PowerAppearance appearance: PowerAppearance {}
    TmuxList { width: 320; height: 200; model: [{created: 100, attached: true, windows: [{index: 0, name: "editor"}]}]; sampledAt: 200 }
    property MenuCoordinator coordinator: MenuCoordinator { menus: ({}) }
    property ControlsController controlsController: ControlsController {
        coordinator: coordinator
        actions: startup.controlsActions
        launch: argv => Qt.exit(9)
    }
    ControlsContent { actions: startup.controlsActions; width: 480; height: implicitHeight }
    ActionList { model: [{key: "lock", label: "Lock"}]; icons: Icons }
    MenuSurface {
        width: 200
        Column {
            MenuRow { glyph: Icons.lock; text: "Lock" }
            MenuError { id: errorLabel; text: "Test error" }
        }
    }
    Component.onCompleted: Qt.callLater(() => {
        if (startup.powerAction !== "/fake bin/power-action"
                || startup.tmux !== "/fake bin/tmux"
                || startup.screenshotCopy !== "/fake bin/screenshot-copy"
                || startup.screenshotDirectory !== "/synthetic home/#captures/Pictures/Screenshots"
                || startup.screenshotFolder.toString() !== "file:///synthetic home/%23captures/Pictures/Screenshots"
                || JSON.stringify(startup.controlsActions.map(action =>
                    [action.key, action.label, action.menu ?? null, action.command ?? null])) !== JSON.stringify([
                    ["p", "Power", "power", null],
                    ["t", "tmux", "tmux", null],
                    ["s", "Screenshots", "screenshots", null],
                    ["c", "Clipboard", null, ["/fake bin/kitty", "--class", "cq-picker", "--title", "Clipboard history",
                        "-o", "map=enter", "-o", "map=space", "-e", "/synthetic home/#captures/.local/bin/cq", "ls"]],
                    ["b", "Bluetooth", null, ["/fake bin/kitty", "-T", "bluetuith", "-e", "/fake bin/bluetuith"]],
                    ["i", "Internet", null, ["/fake bin/kitty", "-T", "nmtui", "-e", "/fake packages/networkmanager/bin/nmtui"]],
                    ["v", "Volume", null, ["/fake bin/kitty", "-T", "pulsemixer", "-e", "/fake bin/pulsemixer"]]
                ])
                || errorLabel.text !== "Test error" || Theme.fontSize <= 0 || appearance.preferredWidth <= 0)
            Qt.exit(1);
        else {
            console.log("THEME_LOAD_OK");
            Qt.quit();
        }
    })
}
