import QtQuick

Text {
    visible: text !== ""
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    color: Theme.critical
    font.family: Theme.uiFont
    font.pixelSize: Theme.fontSize
}
