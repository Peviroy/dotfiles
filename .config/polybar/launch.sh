#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

#bspc config top_padding 0
#bspc config bottom_padding 0
# Launch bar1 and bar2
if [ "$1" == "shape" ]
then
	bspc config top_padding 36
	bspc config bottom_padding 0
	for monitor in $( bspc query -M --names); do
		MONITOR="$monitor" polybar main -c "$HOME"/.config/polybar/themes/shapes/config.ini &
	done
else
	bspc config top_padding 43
	bspc config bottom_padding 43
	for monitor in $( bspc query -M --names); do
		if [ "$(xrandr -q | grep primary | awk '{print $1}')" == "$monitor" ]; then
				MONITOR=$monitor polybar -c "$HOME"/.config/polybar/themes/nord/dark-config nord-down &
		fi
		MONITOR=$monitor polybar nord-top -c "$HOME"/.config/polybar/themes/nord/dark-config &
	done
fi

echo "Bars launched..."
