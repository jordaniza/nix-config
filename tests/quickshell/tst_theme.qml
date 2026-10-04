import QtQuick
import Quickshell
import "theme"
import "shared"

ShellRoot {
    property PowerAppearance appearance: PowerAppearance {}
    ActionList { model: [{key: "lock", label: "Lock"}]; icons: Icons }
    MenuSurface {
        width: 200
        Column {
            MenuRow { glyph: Icons.lock; text: "Lock" }
            MenuError { id: errorLabel; text: "Test error" }
        }
    }
    Component.onCompleted: Qt.callLater(() => {
        if (errorLabel.text !== "Test error" || Theme.fontSize <= 0 || appearance.preferredWidth <= 0)
            Qt.exit(1);
        else {
            console.log("THEME_LOAD_OK");
            Qt.quit();
        }
    })
}
