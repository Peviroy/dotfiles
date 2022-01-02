#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
if [ "$1" == "light" ]
then
	exit
else
	for monitor in $( bspc query -M --names); do
		if [ $(xrandr -q | grep primary | awk '{print $1}') == $monitor ]; then
				MONITOR=$monitor polybar -c $HOME/.config/polybar/themes/nord/dark-config nord-down &
		fi
		MONITOR=$monitor polybar -c $HOME/.config/polybar/themes/nord/dark-config nord-top &
	done
fi

echo "Bars launched..."
