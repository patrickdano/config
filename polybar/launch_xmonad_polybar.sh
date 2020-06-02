#!/usr/bin/env bash 

# Terminate already running bar instances 
killall -q polybar 

# Wait until the processes have been shut down 
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done 

#for m in $(polybar --list-monitors | cut -d":" -f1); do
#	WIRELESS=$(ls /sys/class/net/ | grep ^wl | awk 'NR==1{print $1}') MONITOR=$m polybar --reload mainbar-spectrwm & 
#done 

#DISPLAY1="$(xrandr -q | grep 'eDP1\|VGA-1' | cut -d ' ' -f1)" [[ ! -z "$DISPLAY1" ]] && MONITOR="$DISPLAY1" polybar top1 &

DISPLAY1="$(polybar --list-monitors | grep "DP-2" | cut -d":" -f1)" 
DISPLAY2="$(polybar --list-monitors | grep "DVI-I-1" | cut -d":" -f1)" 
MONITOR="$DISPLAY1" polybar mainbar-xmonad &
MONITOR="$DISPLAY1" polybar topbar-xmonad &
MONITOR="$DISPLAY2" polybar topbar2-xmonad &

echo "Bars launched..."

