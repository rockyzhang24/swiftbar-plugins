#!/usr/bin/env bash

# <bitbar.title>Yabai Stats</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Rocky Zhang</bitbar.author>
# <bitbar.author.github>yanzhang0219</bitbar.author.github>
# <bitbar.desc>Display the workspaces on each monitor and the layout of the current workspace</bitbar.desc>
# <bitbar.dependencies>yabai, skhd, jq</bitbar.dependencies>

# SwiftBar needs this
export PATH="/usr/local/bin:$PATH"

# ANSI colors
COLOR_FOCUSED='\\\033[38;5;196m'  # color for the id of the focused workspace
COLOR_VISIBLE='\\\033[38;5;40m'  # color for the ids of the visible workspaces
RESET='\\\033[0m'

# JSON raw data of all workspaces
yabai_spaces=$(yabai -m query --spaces)

# The workspace id that is currently focused
space_focused=$(echo ${yabai_spaces} | jq '.[] | select(.focused == 1) | .index')

# All the ids of visible workspaces not including the focused one (each non-focused monitor has one visible workspace)
spaces_visible=$(yabai -m query --spaces | jq -rj '.[] | select(.visible == 1 and .focused != 1) | .index')

# Workspaces for each monitor and color the focused workspace
# x | x x | x ---> means totally three monitors, the left one has one workspace, the middle one has two, and the right one has one
spaces=$(yabai -m query --displays | jq -r 'sort_by(.frame.x) | map(.spaces | join(" ")) | join(" │ ")' \
         | sed -r "s/${space_focused}/${COLOR_FOCUSED}${space_focused}${RESET}/")

# Color the visible workspaces
if [[ -n ${spaces_visible} ]]; then
  spaces=$(echo ${spaces} | sed -r "s/([${spaces_visible}][[:space:]]|[${spaces_visible}]\$)/${COLOR_VISIBLE}\1${RESET}/g")
fi

# The layout of the focused workspace: B for bsp, F for float and S for stack
cur_space_type=$(echo ${yabai_spaces} | jq -r '.[] | select(.focused == 1) | .type | if . == "bsp" then "B" elif . == "float" then "F" elif . == "stack" then "S" else . end')

echo -e "${spaces} - ${cur_space_type} | ansi=true"
