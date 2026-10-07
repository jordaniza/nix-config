pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../theme"

FloatingWindow {
    id: menu
    default property alias contents: frame.contentData
    required property Item focusTarget
    property int preferredWidth: surface.implicitWidth
    property var focusedMonitorName: () => Hyprland.focusedMonitor?.name
    property var dispatch: command => Hyprland.dispatch(command)
    signal opened()

    visible: false
    implicitWidth: preferredWidth
    implicitHeight: surface.implicitHeight
    minimumSize: Qt.size(implicitWidth, implicitHeight)
    maximumSize: minimumSize
    color: Theme.transparent

    function requestFocus() {
        if (!visible || !backingWindowVisible)
            return;
        focusTarget.forceActiveFocus();
        dispatch("focuswindow title:^(" + title + ")$");
    }

    function open() {
        if (!visible) {
            const focusedName = focusedMonitorName();
            let target = Quickshell.screens.find(screen => screen.name === focusedName);
            if (!target && Quickshell.screens.length === 1)
                target = Quickshell.screens[0];
            if (!target) {
                console.error("Cannot open menu: no focused screen available.");
                return false;
            }
            screen = target;
            minimized = false;
            visible = true;
            opened();
        } else {
            minimized = false;
            requestFocus();
        }
        return true;
    }

    function close() { visible = false; }
    onClosed: close()
    onBackingWindowVisibleChanged: requestFocus()

    // Hyprland owns the focus border. Losing focus leaves the menu open.
    readonly property MenuSurface surface: MenuSurface {
        id: frame
        parent: menu.contentItem
        anchors.fill: parent
        bordered: false
    }
}
