import QtQml

QtObject {
    readonly property real widthFraction: 0.48
    readonly property int minimumWidth: 640
    readonly property int maximumWidth: 960
    readonly property int screenInset: 24

    function widthFor(screenWidth) {
        return Math.max(1, Math.min(screenWidth - 2 * screenInset,
            Math.max(minimumWidth, Math.min(maximumWidth, Math.round(screenWidth * widthFraction)))));
    }
}
