#!/bin/bash

wf-recorder_check() {
	if pgrep -x "wf-recorder" > /dev/null; then
		notify-send "Stopping active recording"
		pkill -INT -x wf-recorder
		exit 0
	fi
}

wf-recorder_check

check_screencast_dir() {
	if [ ! -d "$HOME/Videos/Screencasts" ]; then
		mkdir -p "$HOME/Videos/Screencasts"
	fi
}

active() {
	if command -v hyprctl &>/dev/null; then
		hyprctl -k activewindow | \
			jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
	elif command -v swaymsg &>/dev/null; then
		swaymsg -t get_tree | \
			jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'
	else
		notify-send "Error! Could not get active window!"
		exit 0
	fi
}

set -eEuo pipefail

outPath="$HOME/Videos/Screencasts/$(date +%m-%d-%Y_%H-%m-%s).mp4"

case "$1" in
	'active') notify-send "Starting active window recording" && wf-recorder -g "$(active)" -f "$outPath";;
	'area') notify-send "Starting area recording" && wf-recorder -g "$(slurp)" -f "$outPath";;
	'output') notify-send "Starting screen recording" && wf-recorder -f "$outPath";;
	*) notify-send "Error! Recording type not specified!" && exit 0;;
esac


notify-send "Recording saved to" "$outPath"
mpv "$outPath"
