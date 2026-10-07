import QtQuick

LauncherAppearance {
    readonly property int preferredHeight: 412
    readonly property int contentInset: 22
    readonly property int sessionSpacing: 12
    readonly property int scrollStep: 32
    readonly property int cardInset: 16
    readonly property int cardHeaderHeight: 28
    readonly property int cardMetaHeight: 24
    readonly property int cardSectionGap: 12
    readonly property int windowHeight: 28
    readonly property int windowSpacing: 4
    readonly property color cardColor: Qt.tint(Theme.background,
        Qt.rgba(Theme.selection.r, Theme.selection.g, Theme.selection.b, 0.35))

    function columnsFor(width, count) {
        return Math.max(1, Math.min(count, width >= 800 ? 3 : width >= 520 ? 2 : 1));
    }

    function cardHeightFor(count) {
        return 2 * cardInset + cardHeaderHeight + cardMetaHeight + 2 * cardSectionGap
            + count * windowHeight + Math.max(0, count - 1) * windowSpacing;
    }
}
