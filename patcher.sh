#!/bin/sh

SYS=' B8 C9 00 00 00 0F 05'    # mov eax,0C9h; syscall
OLD=' 55 48 89 FD 48 85 C0 74' # push rbp; mov rbp,rdi; test rax,rax jz ... 
NEW=' 48 C7 C0 00 00 00 00 C3' # mov rax,0; ret

BSYS="$(printf '%s' "$SYS" | sed 's/ /\\x/g')"
BOLD="$(printf '%s' "$OLD" | sed 's/ /\\x/g')"
BNEW="$(printf '%s' "$NEW" | sed 's/ /\\x/g')"

if [ ! -e "$1" ]; then
        printf 2>&1 '%s [FILE]\n' "$0"
        exit 1
fi

bbe -b "28:/$BSYS/" -e "s/$BOLD/$BNEW/" "$1" -o "$1_patched"

