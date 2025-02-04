#!/bin/sh
#
# Clear cache of various system components
#

set -eu

disk_usage() {
	df -k ~ --output=used | tail -n 1
}

usage_diff() {
	gawk -vbefore="$1" -vafter="$2" 'BEGIN {
		diff = (before - after) / 1024;
		printf("%7.02f MiB\n", diff);
		exit;
	}'
}

prune_subsys() {
	local subsys="$1"

	case "$subsys" in
	brew)
		brew cleanup -s
		rm -rf "$(brew --cache)/downloads"
		;;
	apple:garageband)
		# https://smallbusiness.chron.com/delete-garageband-mac-29847.html
		# https://garagebandonpc.com/uninstall/
		rm -rf "/Applications/GarageBand.app"
		rm -rf "/Library/Application Support/GarageBand"
		rm -rf "/Library/Audio/Apple Loops/Apple"
		;;
	apple:xcode)
		# https://stackoverflow.com/questions/31011062/how-to-completely-uninstall-xcode-and-clear-all-settings
		# https://onexlab-io.medium.com/uninstall-xcode-from-macos-eca1b69dc836
		killall Xcode
		xcrun --kill-cache
		#xcodebuild -alltargets clean
		rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
		rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang.$(whoami)/ModuleCache"
		rm -rf /Applications/Xcode.app
		rm -rf ~/Library/Caches/com.apple.dt.Xcode
		rm -rf ~/Library/Developer
		rm -rf ~/Library/MobileDevice
		rm -rf ~/Library/Preferences/com.apple.dt.Xcode.plist
		rm -rf ~/Library/Preferences/com.apple.dt.xcodebuild.plist
		sudo rm -rf /Library/Preferences/com.apple.dt.Xcode.plist
		sudo rm -rf /System/Library/Receipts/com.apple.pkg.XcodeExtensionSupport.bom
		sudo rm -rf /System/Library/Receipts/com.apple.pkg.XcodeExtensionSupport.plist
		sudo rm -rf /System/Library/Receipts/com.apple.pkg.XcodeSystemResources.bom
		sudo rm -rf /System/Library/Receipts/com.apple.pkg.XcodeSystemResources.plist
		sudo rm -rf /private/var/db/receipts/com.apple.pkg.Xcode.bom
		set +x
		;;
	apple:cleanmymac4)
		rm -f "$HOME/Library/LaunchAgents/com.macpaw.CleanMyMac4.Updater.plist"
		rm -f "$HOME/Library/Preferences/com.macpaw.CleanMyMac4.HealthMonitor.plist"
		rm -f "$HOME/Library/Preferences/com.macpaw.CleanMyMac4.Menu.plist"
		rm -f "$HOME/Library/Preferences/com.macpaw.CleanMyMac4.plist"
		rm -rf "$HOME/Library/Caches/com.macpaw.CleanMyMac4"
		rm -rf "$HOME/Library/Caches/com.macpaw.CleanMyMac4.Updater"
		rm -rf "$HOME/Library/Group Containers/"*".com.macpaw.CleanMyMac4"
		rm -rf "$HOME/Library/Logs/CleanMyMac X Menu"
		rm -rf "$HOME/Library/Logs/com.macpaw.CleanMyMac4"
		rm -rf "$HOME/Library/WebKit/com.macpaw.CleanMyMac4"
		rm -rf "$HOME/Library/Application Support/CleanMyMac X"
		rm -rf "$HOME/Library/Application Support/CleanMyMac X HealthMonitor"
		rm -rf "$HOME/Library/Application Support/CleanMyMac X Menu"
		rm -rf "$HOME/Library/Caches/SentryCrash/CleanMyMac X HealthMonitor"
		rm -rf "$HOME/Library/Caches/SentryCrash/CleanMyMac X Menu"
		rm -rf "$HOME/Library/Caches/SentryCrash/CleanMyMac X"
		rm -f "$HOME/Library/Application Support/CleanMyMac X/".???*.*
		;;
	composer)
		composer clear-cache
		;;
	ccache)
		ccache --clear
		;;
	docker:container)
		docker container prune -f
		;;
	docker:image)
		docker image prune -f
		;;
	docker:builder)
		docker builder prune -fa
		;;
	docker:disk-image)
		docker run --privileged --pid=host docker/desktop-reclaim-space
		;;
	docker)
		prune_subsys docker:container
		prune_subsys docker:image
		prune_subsys docker:builder
		prune_subsys docker:disk-image
		;;
	npm)
		npm cache clean --force
		;;
	pnpm)
		pnpm store prune
		;;
	yarn)
		yarn cache clean
		;;
	cpanm)
		rm -rf ~/.cpanm/work
		;;
	draft)
		rm -rf ~/.draft/cache
		;;
	helm)
		rm -rf ~/.helm/repository/local/
		;;
	pip)
		pip cache purge
		;;
	pipenv)
		rm -rf ~/Library/Caches/pipenv/
		;;
	deno)
		rm -rf ~/Library/Caches/deno/
		;;
	jetbrains)
		rm -rf ~/Library/Caches/JetBrains/*
		;;
	node-gyp)
		rm -rf ~/.node-gyp/ ~/Library/Caches/node-gyp/
		;;
	tabnine)
		rm -rf ~/.tabnine/
		;;
	esac
}

cleanup() {
	local subsys="$1"
	local before after output

	printf "=> Cleaning $subsys\n"
	before=$(disk_usage)
	output=$(prune_subsys "$subsys" 2>&1 || :)
	after=$(disk_usage)
	diff=$(usage_diff "$before" "$after")

	printf "Freed: %s\n\n%s\n\n" "$diff" "$output"
}

main() {
	test -n "${1:-}" || set -- brew composer docker npm yarn node-gyp helm pipenv

	for subsys in "$@"; do
		cleanup "$subsys"
	done
}

main "$@"
