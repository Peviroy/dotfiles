# !/bin/bash
# @Forked from: https://github.com/yedhink

# install wmctrl. Its a prerequisite to make this script work.

# Launch it in your i3/bspc config file
#
# obviously, make it executable : # chmod +x init_workspace.sh
# HAVE FUN !


# App you want to start :
apps=(
 "st"
)

# Which workspace to assign your wanted App :
workspaces=(
"I"
)

# counter of opened windows
owNB=0

# add paths of apps to array
# app[i] workspaces[i] arr[i]
arr=(
'/usr/local/bin'
)

for iwin in ${!apps[*]}
do
    while [ "$owNB" -lt "$iwin" ] # wait before start other programs
    do
        owNB=$(wmctrl -l | wc -l) # Get number of actual opened windows
    done

    bspc desktop ${workspaces[$iwin]} -f # move in wanted workspace
		# i3-msg workspace ${workspaces[$iwin]}

    ${arr[$iwin]}/${apps[$iwin]} & # start the wanted app
done

# wait for a while
sleep 5

(/usr/bin/neofetch | lolcat -d 300 -s 10) > /dev/pts/0
(echo "Time to break some stuff" | lolcat -d 300 -s 10 -af) > /dev/pts/0
