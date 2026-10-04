import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../shared"
import "../../theme"

PopupWindow {
    id: drawer
    required property string copyCommand
    required property url folder
    preferredWidth: appearance.preferredWidth
    anchors.bottom: true
    margins.bottom: surface.screenInset
    focusTarget: historyLoader.item
    WlrLayershell.namespace: "screenshot-history"
    onOpened: controller.errorMessage = ""

    property ScreenshotAppearance appearance: ScreenshotAppearance {}
    property ScreenshotController controller: ScreenshotController {
        command: drawer.copyCommand
        process: Process {
            stderr: SplitParser { onRead: data => console.error("[screenshots]", data) }
        }
        onCopied: drawer.close()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: drawer.appearance.contentSpacing
        Loader {
            id: historyLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Destroy the directory model and previews when the drawer closes.
            active: drawer.visible
            sourceComponent: ScreenshotList {
                folder: drawer.folder
                actionsEnabled: !drawer.controller.pending
                onActivated: path => drawer.controller.copy(path)
                onDismissed: drawer.close()
            }
        }
        MenuError {
            Layout.fillWidth: true
            text: drawer.controller.errorMessage
        }
    }
}
