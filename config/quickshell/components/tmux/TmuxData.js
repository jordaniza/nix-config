.pragma library

// Replace control characters; #: escapes colons inside tmux format arguments.
var format = "#{session_id}\t#{session_created}\t#{session_attached}\t#{window_index}\t#{s|[[#:cntrl#:]]| |:window_name}";

function noServer(message) {
    return /^no server running on /.test(message)
        || /^error connecting to .* \(No such file or directory\)\s*$/.test(message);
}

function parse(text) {
    var sessions = {};
    for (var line of text.split("\n")) {
        if (!line.length) continue;
        var fields = line.split("\t");
        if (fields.length !== 5 || !/^\$\d+$/.test(fields[0])
                || !fields.slice(1, 4).every(value => /^\d+$/.test(value)))
            throw new Error("Invalid tmux response");
        var id = fields[0];
        if (!sessions[id]) {
            sessions[id] = {
                id: id,
                created: Number(fields[1]),
                attached: Number(fields[2]) > 0,
                windows: []
            };
        }
        sessions[id].windows.push({index: Number(fields[3]), name: fields[4]});
    }
    var result = Object.values(sessions);
    result.forEach(session => session.windows.sort((a, b) => a.index - b.index));
    return result.sort((a, b) => Number(b.attached) - Number(a.attached)
        || a.created - b.created || Number(a.id.slice(1)) - Number(b.id.slice(1)));
}

function boardRows(sessions, columns) {
    var rows = [];
    for (var index = 0; index < sessions.length; index += columns)
        rows.push(sessions.slice(index, index + columns));
    return rows;
}

function age(created, now) {
    var seconds = Math.max(0, now - created);
    if (seconds < 60) return "<1m";
    if (seconds < 3600) return Math.floor(seconds / 60) + "m";
    if (seconds < 86400) return Math.floor(seconds / 3600) + "h";
    return Math.floor(seconds / 86400) + "d";
}
