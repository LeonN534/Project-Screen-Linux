#!/usr/bin/env sh

SYSTEM_LANG="$LANG"
export LANG='POSIX'
exec >/dev/null 2>&1

PRIMARY_MONITOR=$(xrandr --query | grep " connected primary" | awk '{print $1}')

if [ -z "$PRIMARY_MONITOR" ]; then
    exit 1
fi

SECONDARY_MONITOR=$(xrandr --query | grep " connected" | grep -v "$PRIMARY_MONITOR" | awk '{print $1}')

if [ -z "$SECONDARY_MONITOR" ]; then
    exit 1
fi

PRIMARY_RES=$(xrandr --query | grep " connected primary" | awk '{print $4}' | sed 's/+.*//')

if [ -z "$PRIMARY_RES" ]; then
    exit 1
fi

A="PC screen only"
B="Duplicate"
C="Extend"
D="Second screen only"

options="$A\n$B\n$C\n$D"

selected=$(echo -e "$options" | rofi -dmenu -theme-str '@import "config-project-screen.rasi"' -markup-rows)

case "$selected" in
    *"$A_"*)
        mons -o
        ;;
    *"$B_"*)
        mons -d
        xrandr --output $SECONDARY_MONITOR --mode $PRIMARY_RES
        ;;
    *"$C_"*)
        mons -e right
        xrandr --output $SECONDARY_MONITOR --mode $PRIMARY_RES
        ;;
    *"$D_"*)
        mons -s
        xrandr --output $SECONDARY_MONITOR --mode $PRIMARY_RES
        ;;
esac

exit ${?}