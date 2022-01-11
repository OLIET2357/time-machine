#!/bin/sh

if [ ! -e "$1" ]; then
	printf >&2 '%s BIN [TIME [NOEXECUTE]]\n' "$0"
	exit 1
fi

case "$1" in
	*/* ) BIN="$1";; 
	*) BIN=./"$1" ;;
esac

DIR=$(dirname "$0")

TYPE=$(file "$BIN")

case "$TYPE" in
	*ELF?64-bit* ) : ;;
	*) printf >&2 '"%s" is not ELF 64-bit binary\n' "$BIN"
	exit 1 ;;
esac

case "$TYPE" in
	*dynamically?linked* ) echo >&2 'Hooking'
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
		echo "env LD_PRELOAD=$DIR/hook.so $BIN"
	fi ;;
	*statically?linked* ) echo >&2 'Patching'
	chmod +x "$DIR"/patcher.sh
	if [ -z "$2" ]; then
		"$DIR"/patcher.sh "$BIN"
	else
		"$DIR"/patcher.sh "$1" "$2"
	fi
	chmod +x "${BIN}_patched"
	if [ -z "$3" ]; then
		"${BIN}_patched"
	else
		echo
		echo 'Execute This'
		echo "${BIN}_patched"
	fi ;;
	*) echo >&2 'Unknown Type'
	exit 1 ;;
esac

