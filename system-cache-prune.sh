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
	brew)
		brew cleanup -s
		;;
	apple:garageband)
		# https://smallbusiness.chron.com/delete-garageband-mac-29847.html
		rm -rf "/Applications/GarageBand.app"
		rm -rf "/Library/Application Support/GarageBand"
		rm -rf "/Library/Audio/Apple Loops/Apple"
		;;
	composer)
		composer clear-cache
		;;
	docker:container)
		docker container prune -f
		;;
	docker:image)
		docker image prune -f
		;;
	docker:disk-image)
		docker run --privileged --pid=host docker/desktop-reclaim-space
		;;
	docker)
		prune_subsys docker:container
		prune_subsys docker:image
		prune_subsys docker:disk-image
		;;
	npm)
		npm cache clean --force
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

main() {
	test -n "${1:-}" || set -- brew composer docker npm yarn

	for subsys in "$@"; do
		cleanup "$subsys"
	done
}

main "$@"
