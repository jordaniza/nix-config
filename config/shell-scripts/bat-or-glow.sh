#!/usr/bin/env bash

# Check if exactly one argument is provided and it's a markdown file
if [ $# -eq 1 ] && [ -f "$1" ] && [[ "$1" =~ \.(md|markdown)$ ]]; then
    # Single markdown file, use glow
    glow -p "$1"
else
    # All other cases, use bat
    bat "$@"
fi