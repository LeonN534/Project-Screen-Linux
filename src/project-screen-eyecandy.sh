#!/usr/bin/env sh

# Desc:   Windows-like script for project screen.
# Author: LeonN534 <alternate-se7en@pm.me>
# URL:    

# SPDX-License-Identifier: ISC

# shellcheck disable=SC2016

SYSTEM_LANG="$LANG"
export LANG='POSIX'
exec >/dev/null 2>&1

ICON_DIR=""
PC_SCREEN_ONLY_ICON="$ICON_DIR/pc-screen-only.png"
DUPLICATE_ICON="$ICON_DIR/duplicate.png"
EXTEND_ICON="$ICON_DIR/extend.png"
SECOND_SCREEN_ONLY_ICON="$ICON_DIR/second-screen-only.png"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

packages=("xrandr" "mons" "rofi")

for package in "${packages[@]}"; do
    if ! command_exists "$package"; then
        dunstify 'Project screen' "$package! not found!" \
            -h string:synchronous:project-screen \
            -a "project-screen" \
            -i "dialog-error" \
            -u normal
        exit 1
    fi
done


PRIMARY_MONITOR=$(xrandr --query | grep " connected primary" | awk '{print $1}')

if [ -z "$PRIMARY_MONITOR" ]; then
    dunstify 'Project screen' "Could not detect primary monitor!" \
         -h string:synchronous:project-screen \
         -a "project-screen" \
         -i "dialog-error" \
         -u normal
    exit 1
fi

SECONDARY_MONITOR=$(xrandr --query | grep " connected" | grep -v "$PRIMARY_MONITOR" | awk '{print $1}')

if [ -z "$SECONDARY_MONITOR" ]; then
    dunstify 'Project screen' "No secondary monitor found!" \
         -h string:synchronous:project-screen \
         -a "project-screen" \
         -i "dialog-error" \
         -u normal
    exit 1
fi

PRIMARY_RES=$(xrandr --query | grep " connected primary" | awk '{print $4}' | sed 's/+.*//')

if [ -z "$PRIMARY_RES" ]; then
    dunstify 'Project screen' "Could not detect primary resolution!" \
        -h string:synchronous:project-screen \
        -a "project-screen" \
         -i "dialog-error" \
        -u normal
    exit 1
fi

A_='💻'
A="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${A_}</span>   PC screen only"
B_='💻💻'
B="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${B_}</span>   Duplicate"
C_='💻🖥️'
C="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${C_}</span>   Extend"
D_='🖥️'
D="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${D_}</span>   Second screen only"

options="$A\n$B\n$C\n$D"

selected=$(echo -e "$options" | rofi -dmenu -theme-str '@import "config-project-screen.rasi"' -markup-rows)

case "$selected" in
    *"$A_"*)
        mons -o
        dunstify 'Project screen' "Projecting only primary monitor" \
            -h string:synchronous:project-screen \
            -a "project-screen" \
            -I "$PC_SCREEN_ONLY_ICON" \
            -u normal
        ;;
    *"$B_"*)
        mons -d
        xrandr --output $SECONDARY_MONITOR --mode $PRIMARY_RES
        dunstify 'Project screen' "Duplicating monitor" \
            -h string:synchronous:project-screen \
            -a "project-screen" \
            -I "$DUPLICATE_ICON" \
            -u normal
        ;;
    *"$C_"*)
        mons -e right
        xrandr --output $SECONDARY_MONITOR --mode $PRIMARY_RES
        dunstify 'Project screen' "Extending primary monitor" \
            -h string:synchronous:project-screen \
            -a "project-screen" \
            -I "$EXTEND_ICON" \
            -u normal
        ;;
    *"$D_"*)
        mons -s
        xrandr --output $SECONDARY_MONITOR --mode $PRIMARY_RES
        dunstify 'Project screen' "Projecting only secondary monitor" \
            -h string:synchronous:project-screen \
            -a "project-screen" \
            -I "$SECOND_SCREEN_ONLY_ICON" \
            -u normal
        ;;
esac

exit ${?}