#!/bin/sh

# Query active window state
STATE=$(hyprctl -j activewindow | jq -r '.floating')

if [ "$STATE" = "true" ]; then
	# Current window is floating → go to next tiled window
	hyprctl dispatch cyclenext tiled
else
	# Current window is tiled → go to next floating window
	hyprctl dispatch cyclenext floating
fi
