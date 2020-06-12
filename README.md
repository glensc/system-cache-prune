# system-cache-prune

Clear caches from the system.

This tool is intended to cleanup various caches on machine where free
disk availability is regularly critical.

## Usage

```
$ system-cache-prune.sh
$ system-cache-prune.sh subsystem1 subsystem2
```

## Subsystems

- [composer]: Deletes all content from Composer's cache directories.
- [docker]: Remove all unused containers, images (both dangling and unreferenced).
- [yarn]: Remove the shared cache files.

[composer]: https://getcomposer.org/doc/03-cli.md#clear-cache-clearcache-cc
[docker]: https://docs.docker.com/engine/reference/commandline/system_prune/
[yarn]: https://yarnpkg.com/cli/cache/clean
