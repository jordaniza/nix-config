#!/bin/sh

# A custom CLI for managing CopyQ history.

case "$1" in
"" | --help)
	echo "Usage: cq [COMMAND]"
	echo ""
	echo "A simple CLI to manage CopyQ."
	echo ""
	echo "Commands:"
	echo "  list        Show a searchable history menu with fzf."
	echo "  clear       Clear all items from the clipboard history."
	echo "  [numbers]   Print the content of one or more items by index."
	;;

list)

	# Use a "here document" (<< 'EOF') to pass the script safely to CopyQ
	selection=$(
		copyq eval - <<'EOF' | fzf --tac | awk -F. '{print $1}'
if (size() > 0) {
var l = [];
for (var i = 0; i < size(); ++i) {
l.push(i + ". " + str(read(i)).split("\n")[0]);
}
print(l.join("\n"));
}
EOF
	)

	if [ -n "$selection" ]; then
		copyq select "$selection"
	fi
	;;

clear)
	count=$(copyq count)
	if [ "$count" -gt 0 ]; then
		copyq remove $(seq 0 $((count - 1)))
	fi
	echo "CopyQ history cleared."
	;;

*)
	copyq read "$@"
	;;
esac
