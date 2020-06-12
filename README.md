# system-cache-prune

Clear caches from the system.

This tool is intended to cleanup various caches on machine where free
disk availability is regularly critical.

I got tried of remembering which command does the cleanup, is it
- `yarn cache-clear`, `yarn clear-cache`, `yarn clear cache`?
- `composer clean cache`?

so I wrote this script and polished it.

## Usage

```
$ system-cache-prune.sh
$ system-cache-prune.sh subsystem1 subsystem2
```

## Subsystems

- [brew]: Remove stale lock files and outdated downloads for all formulae and casks, and remove old versions of installed formulae.
- [composer]: Deletes all content from Composer's cache directories.
- [docker]: Remove all unused containers, images (both dangling and unreferenced).
- [npm]: Delete all data out of the cache folder.
- [yarn]: Remove the shared cache files.

[brew]: https://docs.brew.sh/FAQ#how-do-i-uninstall-old-versions-of-a-formula
[composer]: https://getcomposer.org/doc/03-cli.md#clear-cache-clearcache-cc
[docker]: https://docs.docker.com/engine/reference/commandline/system_prune/
[yarn]: https://yarnpkg.com/cli/cache/clean
[npm]: https://docs.npmjs.com/cli-commands/cache.html
