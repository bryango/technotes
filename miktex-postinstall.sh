#!/bin/bash
# miktex post installation for arch linux
# ... based on:
# - https://aur.archlinux.org/packages/miktex
# - https://github.com/archlinuxcn/repo/tree/master/archlinuxcn/miktex

MIKTEX_USER_BIN=$HOME/apps/miktex/bin

/opt/miktex/bin/miktexsetup \
	--user-link-target-directory="$MIKTEX_USER_BIN" \
	--modify-path=no \
	--verbose \
	finish

export PATH="$PATH:$MIKTEX_USER_BIN"

# run miktex console GUI, setup mirrors & update
# re-run `miktexsetup` to ensure complete setup
