#!/bin/sh

if [ ! -e "$1" ]; then
	printf >&2 '%s BIN [TIME [NOEXECUTE]]\n' "$0"
	exit 1
fi

BIN="$1"
if echo "$1" | grep -E '^[^/]+$'; then
	BIN=./"$1"
fi

DIR=$(dirname "$0")

TYPE=$(file "$BIN")

if echo "$TYPE" | grep 'ELF 64-bit' >/dev/null; then
	:
else
	echo >&2 'FILE is not ELF 64-bit binary'
	exit 1
fi

if echo "$TYPE" | grep 'dynamically linked' >/dev/null; then
	echo >&2 'Hooking'
	if [ -z "$2" ]; then	
		make >&2 -C "$DIR"
	else
		make >&2 -C "$DIR" CFLAGS=-DTIME="$2"
	fi
	if [ -z "$3" ]; then
		env LD_PRELOAD="$DIR"/hook.so "$BIN"
	else
		echo
		echo 'Execute This'
		echo "env LD_PRELOAD=$DIR/hook.so ./$BIN"
	fi
elif echo "$TYPE" | grep 'statically linked' >/dev/null; then
	echo >&2 'Patching'
	chmod +x "$DIR"/patcher.sh
	if [ -z "$2" ]; then
		"$DIR"/patcher.sh "$BIN"
	else
		"$DIR"/patcher.sh "$1" "$2"
	fi
	if [ -z "$3" ]; then
		"${BIN}_patched"
	else
		echo
		echo 'Execute This'
		echo "${BIN}_patched"
	fi
else
	echo >&2 'Unknown Type'
	exit 1
fi

