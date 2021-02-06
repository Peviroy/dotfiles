#!/bin/bash
curl $(grep -v '^#' $HOME/.config/.clash_subscription | xargs -d '\n') -o $HOME/.config/clash/config.yaml
/usr/bin/clash 
