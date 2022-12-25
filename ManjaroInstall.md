# Installing Manjaro, the Arch way, on Btrfs

### Major References

[ManjaroArchWay]: https://amaikinono.github.io/install-minimal-manjaro.html
[Arch]: https://wiki.archlinux.org/title/Installation_guide
[Altercation]: https://wiki.archlinux.org/title/Installation_guide

* The Arch way:
  * Official: [[Arch]]
  * Btrfs & more: [[Altercation]]

* Personalized:
  * Manjaro: [[ManjaroArchWay]]
  * Btrfs: see also https://github.com/egara/arch-btrfs-installation.

All commands are run with `root`. Be **EXTREMELY CAREFUL!**

## Partitioning

* **Table:** GPT
* **Naming:** `by-partlabel` and `by-label`. 
  
> See: https://wiki.archlinux.org/title/Persistent_block_device_naming

  - `by-partlabel` is the new standard. Use this if possible. 
  - `by-label` names are tweaked for compatibility. 

I trust GParted:

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

### swap(end): beginning + end

Two partitions! To enable hibernation. Swap on for `fstabgen`:

```bash
swapon PARTLABEL=swap
swapon PARTLABEL=swapend
```

Later we can set up hibernation, following https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate. Basically,

```bash
# /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="resume=PARTLABEL=swapend"
# Note that _DEFAULT is for normal mode only.
```

Provided that `systemd` HOOKS are set up in `/etc/mkinitcpio.conf`, as described below.

### (btr)system: btrfs

> We mostly follows [[Altercation]]. <br>
> See: https://wiki.archlinux.org/title/User:Altercation/Bullet_Proof_Arch_Install#Create_and_mount_BTRFS_subvolumes

However, we make use of `PARTLABEL` instead of `LABEL`, e.g.

```bash
## mount options
o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime

## intial mount for setup [[Altercation]]
mount -t btrfs PARTLABEL=system /mnt

## recursive umount
umount -R /mnt

## create btrfs subvols, then:
## [[Altercation]]
mount -t btrfs -o subvol=@root,$o_btrfs PARTLABEL=system /mnt
mount -t btrfs -o subvol=@home,$o_btrfs PARTLABEL=system /mnt/home
mount -t btrfs -o subvol=@snapshots,$o_btrfs PARTLABEL=system /mnt/.snapshots
mount --mkdir PARTLABEL=EFI /mnt/boot/efi  ## /efi for (dual) boot support [[ManjaroArchWay]]
```

Mount script available [here](/cheznous/apps/utils/mount-sys.sh). Run with `root`. BE CAREFUL!

## Bootstrapping Manjaro

> We mostly follow [[ManjaroArchWay]] & [[Altercation]]. <br>
> See: https://amaikinono.github.io/install-minimal-manjaro.html#install-base-packages

Use `basestrap`, and install some kernels (maybe do this later?):
- linux419: very stable
- linux515: latest LTS

## fstab

Remember to `swapon`, and mount correctly with `$o_btrfs`. <br>
Use `LABEL` for compatibility:
```
fstabgen -L /mnt >> /mnt/etc/fstab
```
Tweaked result (UUID censored):
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

Swap priority tweaked with `pri=`. Note that `swapend` has a low priority and is mainly used for hibernation. See https://wiki.archlinux.org/title/Swap#Priority.

## chroot & nspawn

```
manjaro-chroot /mnt
```
Sometime `manjaro-chroot -a` will work automatically, but not always.

- Use `passwd` to set root password. <br>
- Add `pts/0` and more to `/etc/securetty` for root login [[Altercation]]. <br>

Test our minimal install:
```
systemd-nspawn --boot -D /mnt
```
_Nice!_ Go back to chroot for more setup:
```
manjaro-chroot /mnt
```
Add some basic packages:
```
pacman -S vim btrfs-progs intel-ucode
```

## base-devel(-meta)

Some very important packages are in the `base-devel` group. <br>
One can simply install an equivalent meta-package: https://aur.archlinux.org/packages/base-devel-meta

Unfortunately this is AUR only. <br>
One can build it in the host and then transfer it to the guest.

Alternatively, simply:
- `pacman -S sudo which` for now, or
- `pacman -S base-devel`


## users & sudo

https://wiki.archlinux.org/title/Users_and_groups

```bash
useradd -m -G wheel bryan
passwd bryan
cd /etc/sudoers.d
visudo 10-installer
```
https://wiki.archlinux.org/title/Sudo#Example_entries
```sudoers
## /etc/sudoers.d/10-installer
%wheel  ALL=(ALL:ALL)  ALL
```

Try to login as `bryan` and `sudo`:
```bash
systemd-nspawn --boot -D /mnt
```
_Nice!_ Go back to chroot for more setup:
```bash
manjaro-chroot /mnt
```

## locale

See [[Arch]] or [[Altercation]]. We only need to do `locale-gen` for now. It seems that the kernel want this.

## initramfs

Use modern `systemd` HOOKS [[Altercation]]. <br>
See also https://wiki.archlinux.org/title/Mkinitcpio

```
## /etc/mkinitcpio.conf
HOOKS=(base systemd autodetect sd-vconsole modconf keyboard block filesystems btrfs fsck)
```

## grub

[[ManjaroArchWay]] & [[Altercation]]:

```
pacman -Syu grub os-prober efibootmgr
```

https://wiki.manjaro.org/index.php/GRUB/Restore_the_GRUB_Bootloader

- Note that we are using **EFI**
- Here we've specified `--bootloader-id=btrjaro`

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=btrjaro --recheck --removable
# ... `--removable` is necessary for me, see [[ManjaroArchWay]] and below
grub-mkconfig -o /boot/grub/grub.cfg
```

### About `--removable`

This is necessary for me with the Samsung Notebook 9:

> https://wiki.archlinux.org/title/GRUB
> 
> Some UEFI firmwares require a bootable file at a known location before they will show UEFI NVRAM boot entries. If this is the case, grub-install will claim efibootmgr has added an entry to boot GRUB, however the entry will not show up in the VisualBIOS boot order selector. The solution is to install GRUB at the default/fallback boot path (i.e. using `--removable`)
> 
> If you use the option --removable then GRUB will be installed to esp/EFI/BOOT/BOOTX64.EFI (or esp/EFI/BOOT/BOOTIA32.EFI for the i386-efi target) and you will have the additional ability of being able to boot from the drive in case EFI variables are reset or you move the drive to another computer. Usually you can do this by selecting the drive itself similar to how you would using BIOS. If dual booting with Windows, be aware Windows usually places an EFI executable there, but its only purpose is to recreate the UEFI boot entry for Windows. If you are installing GRUB on a Mac, you will have to use this option.

```bash
# /etc/default/grub
GRUB_DISABLE_OS_PROBER=false

GRUB_SAVEDEFAULT=false
GRUB_DEFAULT=0
# ... see: https://forum.manjaro.org/t/grub-error-sparse-file-not-allowed/20267

GRUB_CMDLINE_LINUX_DEFAULT="resume=PARTLABEL=swapend"
# Note that _DEFAULT is for normal mode only. To include recovery mode,
GRUB_CMDLINE_LINUX="fbcon=scrollback:256k"
```

Reinstall kernels & boot!

## summary

```
$ pacman -Qe
base 3-2
base-devel-meta 2022.10.06-1  ## sudo, which
btrfs-progs 6.0.1-1
efibootmgr 18-1
grub 2.06.r261.g2f4430cc0-3
intel-ucode 20221108-1
linux419 4.19.265-1
linux419-headers 4.19.265-1
linux515 5.15.78-1
linux515-headers 5.15.78-1
os-prober 1.81-1
vim 9.0.0814-1
```

Boot into the new system. <br>
Proceed to [GnomeInstall.md](./GnomeInstall.md) for basic & GUI setup.
