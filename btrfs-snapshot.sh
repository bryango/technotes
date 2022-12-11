#!/bin/bash
# btrfs snapshot setup

set -xe  # echo & quit on error
name=$1
MNT_BTRSYSTEM=/run/media/root/btrsystem
[[ -z $name ]] && exit 1

sudo mount --mkdir "$MNT_BTRSYSTEM"

# sudo --reset-timestamp: ask for password confirmation
for subvol in root home; do
    # readonly
    sudo --reset-timestamp \
        btrfs subvolume snapshot -r "$MNT_BTRSYSTEM"/{@"$subvol",@snapshots/"$subvol"-"$name"-ro}

    # readwrite
    sudo --reset-timestamp \
        btrfs subvolume snapshot "$MNT_BTRSYSTEM"/{@"$subvol",@snapshots/"$subvol"-"$name"-rw}
done
