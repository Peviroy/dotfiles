#!/usr/bin/env bash
# @author: peviroy

# this requires a service for clash
get_clash_service() {
	SERVICE=$(systemctl is-active --user clash)
}

get_current_filename() {
	SCRIPT_NAME=$(basename -- "$(readlink -f -- "$0")")
}
get_current_filename

# one script one instance only.
for p in $(pgrep -f "$SCRIPT_NAME"); do
	if [[ $p != "$BASHPID" ]]; then
		kill -9 "$p"
	fi
done

# loop
while true; do
	get_clash_service


	# if "toggle", stop script launched before.
	if [[ "$1" == 'toggle' ]]; then
		if [[ "$SERVICE" == 'active' ]]; then
			systemctl stop --user clash
		else
			systemctl start --user clash
		fi
		shift # shift the args
		continue
	fi

	if [[ "$SERVICE" == "active" ]]; then
		echo " "
		sleep 120
	else
		echo ""
		sleep 30
	fi

done
