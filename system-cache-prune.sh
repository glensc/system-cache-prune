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
	docker:container)
		docker container prune -f
		;;
	docker:image)
		docker image prune -f
		;;
	docker)
		prune_subsys docker:container
		prune_subsys docker:image
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
	test -n "${1:-}" || set -- composer docker yarn

	for subsys in "$@"; do
		cleanup "$subsys"
	done
}

main "$@"
