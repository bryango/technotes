# Notes on installing Manjaro

**Features**

- The arch way
- BTRFS

## Partitioning

GPT; name the partition `by-partlabel`, not `by-label`.

![Partition layout](https://user-images.githubusercontent.com/26322692/201986476-5f3e357c-467a-413f-9096-df2d8c6ca9f9.png)

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

Possible to enable hibernation.
