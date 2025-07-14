#!/usr/bin/env bash

PROFILE="Default"
SLACK_URL="https://app.slack.com/client/"

# Try to find an existing Slack window
if wmctrl -l | grep -i "Slack"; then
	# Focus the existing window
	wmctrl -a "Slack" >/dev/null
else
	# Open new Brave window with Slack
	brave --profile-directory="$PROFILE" --new-window "$SLACK_URL" >/dev/null
fi
