# Notes on installing Manjaro

**Features**

- The arch way
- btrfs

## Partitioning

GPT; name the partition `by-partlabel` and `by-label`. 
`by-partlabel` is newer and brief. 
`by-label` names are tweaked for compatibility. 
See: https://wiki.archlinux.org/title/Persistent_block_device_naming

![Partition layout](https://user-images.githubusercontent.com/26322692/202075182-109bfb56-b130-4050-8dbe-17284f14494a.png)


### EFI: 550 MiB

- https://askubuntu.com/a/1313158
> The author of gdisk suggests 550 MiB.
> 
> As per the Arch Linux wiki, to avoid potential problems with some EFIs, ESP size should be at least 512 MiB. 550 MiB is recommended to avoid MiB/MB confusion and accidentally creating FAT16.
> 
- https://wiki.archlinux.org/title/EFI_system_partition
> 
> To prevent interoperability issues with other operating systems it is recommend to make it at least 300 MiB. For early and/or buggy UEFI implementations the size of at least 512 MiB might be needed.
>
> If you give the FAT file system a volume name (i.e. file system label), be sure to name it something other than EFI. That can trigger a bug in some firmwares (due to the volume name matching the EFI directory name) that will cause the firmware to act like the EFI directory does not exist. 

### swap: beginning + end

Possible to enable hibernation. Turn on for `fstabgen`:
```bash
swapon PARTLABEL=swap
swapon PARTLABEL=swapend
```

### system: btrfs

We mostly follows https://wiki.archlinux.org/title/User:Altercation/Bullet_Proof_Arch_Install#Create_and_mount_BTRFS_subvolumes

However, we make use of `PARTLABEL` instead of `LABEL`, e.g.

```bash

o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime

mount -t btrfs PARTLABEL=system /mnt

umount -R /mnt ## recursive

## create btrfs subvols, then:

mount -t btrfs -o subvol=@root,$o_btrfs PARTLABEL=system /mnt
mount -t btrfs -o subvol=@home,$o_btrfs PARTLABEL=system /mnt/home
mount -t btrfs -o subvol=@snapshots,$o_btrfs PARTLABEL=system /mnt/.snapshots
## for (dual) boot support
mount --mkdir PARTLABEL=EFI /mnt/boot/efi
```

## Bootstrapping Manjaro
From now on we mostly follow https://amaikinono.github.io/install-minimal-manjaro.html#install-base-packages
Two kernels:
- linux419: very stable
- linux515: latest LTS

## fstab
Use LABEL (remember to `swapon`, and mount correctly with `$o_btrfs`):
```
fstabgen -L /mnt >> /mnt/etc/fstab
```
Tweaked result (UUID censored, tweak swap priority https://wiki.archlinux.org/title/Swap#Priority):
```
# /dev/sda1 UUID=
LABEL=BOOTEFI       	/boot/efi 	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro	0 0

# /dev/sda3 UUID=
LABEL=btrsystem     	/         	btrfs     	rw,noatime,compress=lzo,ssd,space_cache=v2,subvolid=257,subvol=/@root,subvol=@root	0 0

# /dev/sda3 UUID=
LABEL=btrsystem     	/home     	btrfs     	rw,noatime,compress=lzo,ssd,space_cache=v2,subvolid=258,subvol=/@home,subvol=@home	0 0

# /dev/sda3 UUID=
LABEL=btrsystem     	/.snapshots	btrfs     	rw,noatime,compress=lzo,ssd,space_cache=v2,subvolid=259,subvol=/@snapshots,subvol=@snapshots	0 0

# /dev/sda2 UUID=
LABEL=swap          	none      	swap      	defaults,pri=100	0 0

# /dev/sda4 UUID=
LABEL=swapend       	none      	swap      	defaults,pri=10	0 0
```

## chroot

```
manjaro-chroot /mnt
```
Use `passwd` to set root password.
Add `pts/0` and more to `/etc/securetty` for root login.
```
systemd-nspawn --boot -D /mnt
```
Nice!

Go back to chroot for more setup:
```
manjaro-chroot /mnt
```

## Users, Passwords, Sudo

https://wiki.archlinux.org/title/Users_and_groups

```
useradd -m -G wheel bryan
passwd bryan
```

Install `sudo`, then:
```
cd /etc/sudoers.d
visudo 10-installer
```
https://wiki.archlinux.org/title/Sudo#Example_entries
```
%wheel  ALL=(ALL:ALL)  ALL
```
Try it:
```
systemd-nspawn --boot -D /mnt
```
Nice!

Go back to chroot for more setup:
```
manjaro-chroot /mnt
```

## grub

`pacman -Syu grub os-prober efibootmgr`

https://wiki.manjaro.org/index.php/GRUB/Restore_the_GRUB_Bootloader

```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

```
# /etc/default/grub
GRUB_DISABLE_OS_PROBER=false
```

