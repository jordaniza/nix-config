#!/usr/bin/env zsh

setopt ERR_EXIT NO_UNSET PIPE_FAIL

typeset -g mode=""
typeset -g expected_count=0
typeset -g original_address=""
typeset -g workspace_id=""
typeset -g panes_json="[]"
typeset -g pane_count=0
typeset -g orientation=""

# Error handling

fail() {
	notify-send "Hyprland pane layout" "$1" >/dev/null 2>&1 || true
	exit 1
}

restore_focus() {
	if [[ -n "$original_address" && "$original_address" != "0x0" ]]; then
		hyprctl dispatch focuswindow "address:$original_address" \
			>/dev/null 2>&1 || true
	fi
}

trap restore_focus EXIT

# Environment and current workspace

parse_mode() {
	mode="${1:-}"

	case "$mode" in
	thirds)
		expected_count=3
		;;
	wide-left | wide-right)
		expected_count=2
		;;
	*)
		fail "Usage: pane-layout.sh {thirds|wide-left|wide-right}"
		;;
	esac
}

check_environment() {
	command -v hyprctl >/dev/null || fail "hyprctl is required."
	command -v jq >/dev/null || fail "jq is required."

	local layout_name
	if ! layout_name="$(hyprctl -j getoption general:layout | jq -er '.str')"; then
		fail "Could not determine the active Hyprland layout."
	fi

	[[ "$layout_name" == "dwindle" ]] ||
		fail "Pane presets require the Dwindle layout."
}

capture_workspace() {
	if ! original_address="$(
		hyprctl -j activewindow | jq -er '(.address // empty) | select(length > 0)'
	)"; then
		fail "No active window was found."
	fi

	if ! workspace_id="$(hyprctl -j activeworkspace | jq -er '.id')"; then
		fail "Could not determine the active workspace."
	fi
}

# Pane discovery and validation

query_panes() {
	hyprctl -j clients |
		jq -c --argjson workspace_id "$workspace_id" '
			[
				.[]
				| select(.workspace.id == $workspace_id)
				| select((.mapped // true) == true)
				| select((.hidden // false) == false)
				| select(.floating == false)
				| select((.fullscreen // 0) == 0)
			]
			| sort_by(.at)
		'
}

load_panes() {
	if ! panes_json="$(query_panes)"; then
		fail "Could not read the tiled panes."
	fi

	pane_count="$(print -r -- "$panes_json" | jq -r 'length')"
}

validate_panes() {
	[[ "$pane_count" -eq "$expected_count" ]] ||
		fail "$mode requires exactly $expected_count tiled panes; found $pane_count."

	print -r -- "$panes_json" |
		jq -e --arg address "$original_address" '
			any(.[]; .address == $address)
		' >/dev/null || fail "Select one of the tiled panes first."
}

detect_orientation() {
	if ! orientation="$(
		print -r -- "$panes_json" |
			jq -er '
				def magnitude:
					if . < 0 then -. else . end;

				. as $panes
				| $panes[0] as $first
				| if (
					($panes | map(.at[0]) | unique | length) == ($panes | length)
					and ($panes | all(.[];
						(((.at[1] - $first.at[1]) | magnitude) <= 8)
						and (((.size[1] - $first.size[1]) | magnitude) <= 8)
					))
				) then "horizontal"
				elif (
					($panes | map(.at[1]) | unique | length) == ($panes | length)
					and ($panes | all(.[];
						(((.at[0] - $first.at[0]) | magnitude) <= 8)
						and (((.size[0] - $first.size[0]) | magnitude) <= 8)
					))
				) then "vertical"
				else empty
				end
			'
	)"; then
		fail "The panes must form one horizontal row or vertical column."
	fi

	if [[ "$mode" != "thirds" && "$orientation" != "horizontal" ]]; then
		fail "$mode requires two panes arranged side-by-side."
	fi
}

# Dwindle divider operations

set_parent_ratio() {
	local address="$1"
	local ratio="$2"

	hyprctl dispatch focuswindow "address:$address" >/dev/null ||
		fail "Could not focus pane $address."

	hyprctl dispatch layoutmsg "splitratio $ratio exact" >/dev/null ||
		fail "Could not set the pane ratio."
}

normalize_parent_ratios() {
	local address

	while IFS= read -r address; do
		set_parent_ratio "$address" "1.0"
	done < <(print -r -- "$panes_json" | jq -r '.[].address')
}

# Presets

apply_wide_left() {
	local left_address
	left_address="$(print -r -- "$panes_json" | jq -r '.[0].address')"

	# Hyprland ratio 1.333333 means 2/3 for the left child.
	set_parent_ratio "$left_address" "1.333333"
}

apply_wide_right() {
	local left_address
	left_address="$(print -r -- "$panes_json" | jq -r '.[0].address')"

	# Hyprland ratio 0.666667 means 1/3 for the left child.
	set_parent_ratio "$left_address" "0.666667"
}

apply_thirds() {
	local size_axis=0
	local singleton_address
	local first_address
	local last_address

	[[ "$orientation" == "vertical" ]] && size_axis=1

	# Both parent dividers become 50/50, temporarily producing 50/25/25.
	normalize_parent_ratios
	load_panes

	[[ "$pane_count" -eq 3 ]] ||
		fail "The pane set changed while applying the preset."

	# The 50% pane is attached directly to the outer divider.
	singleton_address="$(
		print -r -- "$panes_json" |
			jq -r --argjson axis "$size_axis" 'max_by(.size[$axis]).address'
	)"
	first_address="$(print -r -- "$panes_json" | jq -r '.[0].address')"
	last_address="$(print -r -- "$panes_json" | jq -r '.[-1].address')"

	if [[ "$singleton_address" == "$first_address" ]]; then
		# 1/3 | (1/3 + 1/3), or the equivalent vertical arrangement.
		set_parent_ratio "$singleton_address" "0.666667"
	elif [[ "$singleton_address" == "$last_address" ]]; then
		# (1/3 + 1/3) | 1/3, or the equivalent vertical arrangement.
		set_parent_ratio "$singleton_address" "1.333333"
	else
		fail "Could not identify the pane attached to the outer divider."
	fi
}

apply_preset() {
	case "$mode" in
	thirds)
		apply_thirds
		;;
	wide-left)
		apply_wide_left
		;;
	wide-right)
		apply_wide_right
		;;
	esac
}

main() {
	parse_mode "${1:-}"
	check_environment
	capture_workspace
	load_panes
	validate_panes
	detect_orientation
	apply_preset
}

main "$@"
