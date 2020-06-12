#!/bin/sh
#
# Clear cache of various system components
#

set -eu

disk_usage() {
	local out
	out=$(df -h ~ --output=used,pcent,target)
	echo "$out" | tail -n1
}

prune_subsys() {
	local subsys="$1"

	case "$subsys" in
	composer)
		composer clear-cache
		;;
	docker)
		docker system prune -af
		;;
	yarn)
		yarn cache clean
		;;
	esac
}

cleanup() {
	local subsys="$1"
	local before after output

	printf "=> Cleaning $subsys\n"
	before=$(disk_usage)
	output=$(prune_subsys "$subsys")
	after=$(disk_usage)
	printf "%s\n%s\n\n%s\n\n" "$before" "$after" "$output"
}

cleanup composer
cleanup docker
cleanup yarn
