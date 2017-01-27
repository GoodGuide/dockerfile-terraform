#!/bin/bash

set -euo pipefail
# set -x
die() {
	echo "$1" >&2
	exit 1
}

main() {
	exec terraform "$@"
}

main $@
