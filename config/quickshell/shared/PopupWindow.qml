pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: popup
    default property alias contents: frame.contentData
    required property Item focusTarget
    property int preferredWidth: surface.implicitWidth
    signal opened()

    visible: false
    anchors { top: true; right: true }
    margins { top: surface.barGap; right: surface.screenInset }
    exclusiveZone: 0
    implicitWidth: preferredWidth
    implicitHeight: surface.implicitHeight
    color: Theme.transparent
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    function open() {
        if (!visible) {
            const focusedName = Hyprland.focusedMonitor?.name;
            let target = Quickshell.screens.find(screen => screen.name === focusedName);
            // A single connected screen is unambiguous; never pick an arbitrary monitor.
            if (!target && Quickshell.screens.length === 1)
                target = Quickshell.screens[0];
            if (!target) {
                console.error("Cannot open popup: no focused screen available.");
                return false;
            }
            screen = target;
            visible = true;
            opened();
        }
        focusTarget.forceActiveFocus();
        grab.active = true;
        return true;
    }

    function close() {
        grab.active = false;
        visible = false;
    }

    // Explicit properties keep these internal objects out of the content slot.
    property HyprlandFocusGrab grab: HyprlandFocusGrab {
        windows: [popup]
        onCleared: popup.close()
    }
    readonly property MenuSurface surface: MenuSurface {
        id: frame
        parent: popup.contentItem
        anchors.fill: parent
    }
}
