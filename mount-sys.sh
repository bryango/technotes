#!/bin/bash
# mount the system for chroot

# echo & quit on error
set -xe

## umount -R /mnt  ## recursive

# options
o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime

# mount btrfs
mount -t btrfs -o subvol=@root,$o_btrfs PARTLABEL=system /mnt
mount -t btrfs -o subvol=@home,$o_btrfs PARTLABEL=system /mnt/home
mount -t btrfs -o subvol=@snapshots,$o_btrfs PARTLABEL=system /mnt/.snapshots

# for (dual) boot support
mount --mkdir PARTLABEL=EFI /mnt/boot/efi
