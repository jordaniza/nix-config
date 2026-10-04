// Decode keys only. Focus, selection and actions remain with the QML caller.
function intent(event, qt, editing) {
    if (editing || event.modifiers & (qt.ControlModifier | qt.AltModifier | qt.MetaModifier))
        return "";
    switch (event.key) {
    case qt.Key_J:
    case qt.Key_Down:
        return "next";
    case qt.Key_Tab:
        return event.modifiers & qt.ShiftModifier ? "previous" : "next";
    case qt.Key_K:
    case qt.Key_Up:
    case qt.Key_Backtab:
        return "previous";
    case qt.Key_Return:
    case qt.Key_Enter:
        return event.isAutoRepeat ? "consume" : "activate";
    case qt.Key_Q:
    case qt.Key_Escape:
        return "dismiss";
    default:
        return "";
    }
}

function move(index, count, delta, wrap) {
    if (count === 0)
        return -1;
    if (index < 0)
        return delta > 0 ? 0 : count - 1;
    return wrap ? (index + delta + count) % count
                : Math.max(0, Math.min(count - 1, index + delta));
}
