#===========================================================================
#  ___      ___  __      ___      ___     ______    ________    _______  
# |"  \    /"  ||" \    |"  \    /"  |   /    " \  |"      "\  /"     "| 
#  \   \  //  / ||  |    \   \  //   |  // ____  \ (.  ___  :)(: ______) 
#   \\  \/. ./  |:  |    /\\  \/.    | /  /    ) :)|: \   ) || \/    |   
#    \.    //   |.  |   |: \.        |(: (____/ // (| (___\ || // ___)_  
#     \\   /    /\  |\  |.  \    /:  | \        /  |:       :)(:      "| 
#      \__/    (__\_|_) |___|\__/|___|  \"_____/   (________/  \_______) 
#
#===========================================================================

bindkey '^v' edit-command-line

bindkey -v

#===============================
#=== Keybinding
#===============================
bindkey -M vicmd "k" vi-insert
bindkey -M vicmd "K" vi-insert-bol
bindkey -M vicmd "l" undo

bindkey -M vicmd "n" vi-backward-char
bindkey -M vicmd "i" vi-forward-char
bindkey -M vicmd "N" vi-beginning-of-line
bindkey -M vicmd "I" vi-end-of-line
bindkey -M vicmd "h" vi-forward-word-end

bindkey -M visual "n" vi-backward-char
bindkey -M visual "i" vi-forward-char
bindkey -M visual "N" vi-beginning-of-line
bindkey -M visual "I" vi-end-of-line
bindkey -M visual "h" vi-forward-word-end

# view history
bindkey -M vicmd "e" down-line-or-history
bindkey -M vicmd "u" up-line-or-history

# search (/)
bindkey -M vicmd "=" vi-repeat-search

# search history
bindkey -M viins '^e' history-incremental-pattern-search-forward
bindkey -M viins '^u' history-incremental-pattern-search-backward



#===============================
#=== Cursor shape
#===============================
# change cursor shape
function zle-keymap-select {
	if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
		echo -ne '\e[1 q'
	elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
		echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Use beam shape cursor
echo -ne '\e[5 q'   # on start up
preexec() {         # for each new prompt.
	echo -ne '\e[5 q'
}
_fix_cursor() {
	echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)



KEYTIMEOUT=1
