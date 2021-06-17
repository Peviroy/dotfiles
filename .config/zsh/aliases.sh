#!/bin/bash

alias arch='sudo pacman -Syyu'
alias hibernate='systemctl hibernate'

alias pf='pfetch'
alias nf='neofetch'

alias ra='ranger'
alias ph='dolphin'
alias lg='lazygit'

alias ym='yadm'
alias ymS='yadm status'
alias ymL='yadm log'
alias ymC='yadm commit'

alias t='trans'
alias te='trans zh:en'
alias tz='trans en:zh'

alias ls="exa -lgh --icons --group-directories-first"
alias la="exa -lgha --icons --group-directories-first"
alias tree="exa --tree --icons -L 2 ."

alias vi='vim'
alias nv='nvim'

alias av='conda activate'
alias dv='conda deactivate'

alias sudo='sudo -E' # preverse-env
alias sra='sudo -E ranger'

alias tbat='sudo tlp bat'
alias tac='sudo tlp ac'

alias p='proxychains'

alias .c='cd $HOME/.config'

alias optimus='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME="nvidia" __VK_LAYER_NV_optimus="NVIDIA_only" __GL_SHOW_GRAPHICS_OSD=1'
