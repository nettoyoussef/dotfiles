#!/bin/bash

# Terminate already running compton instances
killall -q picom

# Wait until the processes have been shut down
while pgrep -u $UID -x picom  >/dev/null; do sleep 1; done

# Launch compton in background, using default config location ~/.config/compton/compton.conf
picom -b --experimental-backends --config /home/eliasy/project_repositories/dotfiles/picom/picom.conf
#picom -b --config $HOME/dotfiles/picom/picom.conf

echo "picom launched..."
