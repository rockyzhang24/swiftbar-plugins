#!/usr/bin/env bash

# <bitbar.title>Yabai Stats</bitbar.title>
# <bitbar.version>v1.1</bitbar.version>
# <bitbar.author>Rocky Zhang</bitbar.author>
# <bitbar.author.github>yanzhang0219</bitbar.author.github>
# <bitbar.desc>Display the workspace ids on each monitor and the layout of the current workspace</bitbar.desc>
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

# Workspaces for each monitor and color the focused workspace
# x | x x | x ---> means totally three monitors, the left one has one workspace, the middle one has two, and the right one has one
spaces=$(yabai -m query --displays | jq -r 'sort_by(.frame.x) | map(.spaces | join(" ")) | join(" │ ")' | \
         sed -r "s/(([[:space:]]|^)${space_focused}([[:space:]]|\$))/${COLOR_FOCUSED}\1${RESET}/")

# Color the visible workspaces
# Get all the ids of visible workspaces not including the focused one (each non-focused monitor has one visible workspace),
# and for each id, color it in the output
while read -r id
do
  spaces=$(echo ${spaces} | sed -r "s/(([[:space:]]|^)${id}([[:space:]]|\$))/${COLOR_VISIBLE}\1${RESET}/g")
done < <(yabai -m query --spaces | jq -r '.[] | select(.visible == 1 and .focused != 1) | .index')

# The layout of the focused workspace: B for bsp, F for float and S for stack
cur_space_type=$(echo ${yabai_spaces} | jq -r '.[] | select(.focused == 1) | .type | if . == "bsp" then "B" elif . == "float" then "F" elif . == "stack" then "S" else . end')

echo -e "${spaces} - ${cur_space_type} | ansi=true"
