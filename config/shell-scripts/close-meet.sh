#!/bin/sh

# Find the Hyprland address of the Meet share popup and close it
ADDR=$(
	hyprctl clients -j |
		jq -r '.[] | select(.title == "meet.google.com is sharing a window.") | .address'
)

if [ -n "$ADDR" ] && [ "$ADDR" != "null" ]; then
	hyprctl dispatch movewindowpixel 99999 99999 address:$ADDR
fi
