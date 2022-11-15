# Notes on installing Manjaro

**Features**

- The arch way
- btrfs

## Partitioning

GPT; name the partition `by-partlabel`, not `by-label`.

![Partition layout](https://user-images.githubusercontent.com/26322692/201990527-a9e993cc-1ec3-43f1-909a-baa675221f9b.png)


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

Possible to enable hibernation. Turn on for `genfstab`:
```bash
swapon PARTLABEL=swap
swapon PARTLABEL=swapend
```

### system: btrfs

We mostly follows https://wiki.archlinux.org/title/User:Altercation/Bullet_Proof_Arch_Install#Create_and_mount_BTRFS_subvolumes

However, we make use of `PARTLABEL` instead of `LABEL`, e.g.

```bash
mount -t btrfs PARTLABEL=system /mnt

## unmount, create subvols, then:

mount -t btrfs -o subvol=@root,$o_btrfs PARTLABEL=system /mnt
mount -t btrfs -o subvol=@home,$o_btrfs PARTLABEL=system /mnt/home
mount -t btrfs -o subvol=@snapshots,$o_btrfs PARTLABEL=system /mnt/.snapshots
```

For dual boot support,
```
mount --mkdir PARTLABEL=EFI /mnt/boot/efi
```



