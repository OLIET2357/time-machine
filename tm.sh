#!/bin/sh

if [ ! -e "$1" ]; then
	printf >&2 '%s [BIN]\n' "$0"
	exit 1
fi

DIR=$(dirname "$0")

TYPE=$(file "$1")

if echo "$TYPE" | grep 'ELF 64-bit' >/dev/null; then
	:
else
	echo >&2 'FILE is not ELF 64-bit binary'
	exit 1
fi

if echo "$TYPE" | grep 'dynamically linked' >/dev/null; then
	echo >&2 'Hooking'
	make >&2 -C "$DIR"
	env LD_PRELOAD="$DIR"/hook.so ./"$1"
elif echo "$TYPE" | grep 'statically linked' >/dev/null; then
	echo >&2 'Patching'
	chmod +x "$DIR"/patcher.sh
	./"$DIR"/patcher.sh "$1"
	./"$1_patched"
else
	echo >&2 'Unknown Type'
	exit 1
fi

