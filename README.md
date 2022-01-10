# time-machine

hook or patch linux binaries to run as if they were on a specified date

# IMPORTANT

This is an _EXPERIMENTAL_ tool.

If it works, you are lucky.

# How to use

[bbe source](https://sourceforge.net/projects/bbe-/files/)

`sudo apt install bbe -y`

`chmod +x tm.sh`

`./tm.sh BIN [TIME]`

This runs binary as specified unix time.

When time is omitted, use epoch time (1970/01/01).

# Worked on

64bit Ubuntu WSL

```
$ uname -a
Linux DESKTOP-***** 4.4.0-19041-Microsoft #1237-Microsoft Sat Sep 11 14:32:00 PST 2021 x86_64 x86_64 x86_64 GNU/Linux
$ ldd show_time_dynamic
        linux-vdso.so.1 (0x00007fffefd83000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fc5a9c10000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fc5a9e24000)
$ ls -l /lib/x86_64-linux-gnu/libc.so.6
lrwxrwxrwx 1 root root 12 Dec 16  2020 /lib/x86_64-linux-gnu/libc.so.6 -> libc-2.31.so
```

Amazon Linux 2 AWS

```
$ uname -a
Linux ip-**-***-**-*.us-east-2.compute.internal 5.10.75-79.358.amzn2.x86_64 #1 SMP Thu Nov 4 21:08:30 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
$ ldd show_time_dynamic
        linux-vdso.so.1 (0x00007ffd299b3000)
        libc.so.6 => /lib64/libc.so.6 (0x00007f0a1e544000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f0a1e8ef000)
$ ls -l /lib64/libc.so.6
lrwxrwxrwx 1 root root 12 Dec  1 18:20 /lib64/libc.so.6 -> libc-2.26.so

```

Also 64bit ELF Binary Linuxes?

The common points are x86-64 && libc.so.6.

# Those below processes are no longer needed

# What to do

If target binary is dynamically linked, you may use system call hooking method.

Else that is statically linked, you could use my patcher.

`file` command shall tell you whether.

# Example

`gcc show_time.c -o show_time_dynamic`

`gcc show_time.c -static -o show_time_static`

```
$ file show_time_dynamic show_time_static
show_time_dynamic: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, ...

show_time_static:  ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, ...
```

Both of them show current date.

## Dynamically linked binary

`make`

`env LD_PRELOAD=./hook.so ./show_time_dynamic`

It shows like that: `Thu Jan 1 00:00:00 1970`. (time depends on Locale)

## Statically linked binary

`sudo apt install bbe -y`

`chmod +x patcher.sh`

`./patcher.sh show_time_static`

`./show_time_static_patched`

Did it work?

# To Specify any date time

Example: `2000/01/01 00:00:00`

Unix Time: `0x386d4380`

## System Call Hooking

simply change `ret` variable of `hook.c`

`time_t ret = 0x386d4380;`

## Patching

change `NEW` variable of `patcher.sh` in little endian

`NEW=' 48 C7 C0 80 43 6D 38 C3'`

Don't forget to add a space at beginning.

# How It works

The patcher rewrite `time` function to just return immediate value EVEN IF STRIPED.

There are other functions to get time such as `clock_gettime`, currently not supported.

# References

[Linux で system call を hook したい](https://qiita.com/thatsdone/items/23cba711af84c5b916ec)

[bbe - binary block editor](http://bbe-.sourceforge.net/bbe.html)
