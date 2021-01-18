#!/bin/bash

#= Yay package name searcher
#= @arg1 name of target
function yayname() {
  echo "Executing: yay -Ssq $1 | grep $1"
  yay -Ssq $1 | grep --color $1
}

#==============================================================
#=== Note: cuase find retures the pashs of files, so it starts with './'
# 	   and its not recommand to use ls to search, uer find instead!
#=== Example:  
#  	rm files starts with dot --- rmexact ".*/\.\w*"
#==============================================================
#= Remove files except for those meeting the regex
#= @arg1 regex
function rmexcept() {
  echo "Executing: find . -not -regex $1 -exec rm {} \;"
  find . -not -regex $1 -exec rm {} \;
}

#= Remove files exact for those meeting the regex
#= @arg1 regex
function rmexact() {
  echo "Executing: find . -not regex $1 -exec rm {} \;"
  find . -regex $1 -exec rm {} \;
}


#= Kill scripts that cannot be find via name via @killall, especially shell scripts
#= @arg1 script name, can be get by $ps -aux | grep script_name
function killScripts(){
  ps -aux | grep $1 | grep -v grep | awk '{ print $2 }' | xargs kill -9
}

