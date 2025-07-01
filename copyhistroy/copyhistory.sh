#!/usr/bin/env bash

## Author : Jack Skehan
## Github : @jackoske
#
## Rofi   : Copy History
#
## Available Styles
#
## style-1     style-2     style-3     style-4     style-5
## style-6     style-7     style-8     style-9     style-10
## style-11    style-12    style-13    style-14    style-15

dir="$HOME/.config/rofi/copyhistroy"
theme='style-9'


# Run Rofi with the clipboard history
cliphist list | rofi -dmenu -p "Clipboard" -theme "${dir}/${theme}.rasi" | cliphist decode | wl-copy