#!/bin/sh

SYS=' B8 C9 00 00 00 0F 05'    # mov eax,0C9h; syscall
OLD=' 55 48 89 FD 48 85 C0 74' # push rbp; mov rbp,rdi; test rax,rax; jz ... 
NEW=' 48 C7 C0 00 00 00 00 C3' # mov rax,0; ret

SYS32=' B8 0D 00 00 00 65 FF 15 10 00 00 00' # mov eax,0Dh; call large dword ptr gs:10h
OLD32=' 8B 00 85 C0 74 15 83 EC 0C 53 FF'    # mov eax,[eax]; test eax eax; jz ...; sub esp,0Ch; push ebx; call eax
NEW32=' B8 00 00 00 00 83 C4 04 5B 5E C3'    # mov eax,0; add esp,4; pop ebx; pop esi; ret

if [ -n "$2" ]; then
	OPE=$(echo "$2" | 
	awk '{
		t=$1*1
		printf "%02X %02X %02X %02X",t%0x100,int(t/0x100)%0x100,int(t/0x10000)%0x100,int(t/0x1000000)%0x100
		}'
	)
	NEW=" 48 C7 C0 $OPE C3"
	NEW32=" B8 $OPE 83 C4 04 5B 5E C3"
fi

BSYS="$(printf '%s' "$SYS" | sed 's/ /\\x/g')"
BOLD="$(printf '%s' "$OLD" | sed 's/ /\\x/g')"
BNEW="$(printf '%s' "$NEW" | sed 's/ /\\x/g')"

BSYS32="$(printf '%s' "$SYS32" | sed 's/ /\\x/g')"
BOLD32="$(printf '%s' "$OLD32" | sed 's/ /\\x/g')"
BNEW32="$(printf '%s' "$NEW32" | sed 's/ /\\x/g')"


if [ ! -e "$1" ]; then
        printf >&2 '%s [FILE]\n' "$0"
        exit 1
fi

bbe -b "28:/$BSYS/" -e "s/$BOLD/$BNEW/" "$1" |
bbe -e "s/$BSYS\\xC3/$BNEW/" |
bbe -b "28:/$BSYS32/" -e "s/$BOLD32/$BNEW32" -o "$1_patched"
