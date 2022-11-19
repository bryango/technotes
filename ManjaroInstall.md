# Installing Manjaro, on Btrfs, in the Arch way

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

All commands are run with `root`. Be EXTREMELY CAREFUL!

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

Mount script available [here](/mount-sys.sh). Run with `root`. BE CAREFUL!

## Bootstrapping Manjaro

> We mostly follow [[ManjaroArchWay]] & [[Altercation]]. <br>
> See: https://amaikinono.github.io/install-minimal-manjaro.html#install-base-packages

Use `basestrap`, and install some kernels (maybe do this later?):
- linux419: very stable
- linux515: latest LTS

## fstab

Use `LABEL` (remember to `swapon`, and mount correctly with `$o_btrfs`):
```
fstabgen -L /mnt >> /mnt/etc/fstab
```
Tweak swap priority: https://wiki.archlinux.org/title/Swap#Priority. <br>
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

## chroot & nspawn

```
manjaro-chroot /mnt
```
Use `passwd` to set root password. <br>
Add `pts/0` and more to `/etc/securetty` for root login.

Test our minimal install [[Altercation]]:
```
systemd-nspawn --boot -D /mnt
```
Nice!

Go back to chroot for more setup:
```
manjaro-chroot /mnt
```
Add some very basic packages:
```
pacman -S vim sudo which btrfs-progs
```

## Users & sudo

https://wiki.archlinux.org/title/Users_and_groups

```bash
useradd -m -G wheel bryan
passwd bryan
cd /etc/sudoers.d
visudo 10-installer
```
https://wiki.archlinux.org/title/Sudo#Example_entries
```sudoers
%wheel  ALL=(ALL:ALL)  ALL
```

Try to login as `bryan` and `sudo`:
```bash
systemd-nspawn --boot -D /mnt
```
Nice!

Go back to chroot for more setup:
```bash
manjaro-chroot /mnt
```

## locale

See [[Arch]] or [[Altercation]]. We only need to select and do `locale-gen` for now. It seems that the kernel want this.

## grub

[[ManjaroArchWay]] & [[Altercation]]:

```
pacman -Syu grub os-prober efibootmgr
```

https://wiki.manjaro.org/index.php/GRUB/Restore_the_GRUB_Bootloader
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

```bash
# /etc/default/grub
GRUB_DISABLE_OS_PROBER=false
```

Reinstall kernels!

