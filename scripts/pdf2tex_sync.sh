#!/bin/bash

file="$1"
line="$2"

[ "${file:0:1}" == "/" ] || file="${PWD}/$file"

exec osascript <<EOF
	tell application "System Events" to set isRunning to exists (processes where name is "iTerm2")

	if not isRunning then
		tell application "iTerm" to activate
		tell application "System Events"
			tell process "iTerm2"
				delay 1
				keystroke "nvim \"$file\" +$line"
				key code 36
			end tell
		end tell
	else
		tell application "iTerm" to activate
		tell application "System Events"
			tell process "iTerm2"
				delay 0.5
				key code 17 using command down
				delay 1
				keystroke "nvim \"$file\" +$line"
				key code 36
			end tell
		end tell
	end if
EOF
