import Quickshell.Io

FileView {
    // Load the small generated configuration before its values are consumed.
    blockLoading: true
    watchChanges: false

    readonly property var settings: JSON.parse(text())
    readonly property string powerAction: settings.powerAction
    readonly property string tmux: settings.tmux
    readonly property var controlsActions: settings.controlsActions
    readonly property string screenshotCopy: settings.screenshotCopy
    readonly property string screenshotDirectory: settings.screenshotDirectory
    readonly property url screenshotFolder: "file://" + encodeURIComponent(screenshotDirectory).replace(/%2F/g, "/")
}
