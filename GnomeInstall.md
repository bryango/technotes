# Install Gnome on Manjaro, the Arch way

[Altercation]: https://wiki.archlinux.org/title/Installation_guide
[Arch]: https://wiki.archlinux.org/title/Installation_guide

## First boot

- Boot into the new system.
- Follow [[Altercation]] and [[Arch]] for basic setup.
- See also https://wiki.archlinux.org/title/systemd-firstboot. 

More specifically, 
  * remove existing setup, e.g. `mv /etc/hostname /etc/hostname.orig`
  * use `systemd-firstboot`
  * use `*ctl` commands by `systemd`

## Network

Best to ensure that hostname, time & stuff is properly set up. Then:
```
pacman -S networkmanager nm-connection-editor
```

## Gnome

- Install minimal group of packages based on the `gnome` group. <br>
  Use meta package: [bryango/aur: gnome-meta](https://github.com/bryango/aur/tree/gnome-meta)
- Install additional packages explicitly: `pacman -S gnome gnome-extra`. 
- Follow https://wiki.archlinux.org/title/GNOME for remaining setup. 

## Xorg & Graphics

- https://wiki.archlinux.org/title/xorg
- https://wiki.archlinux.org/title/Intel_graphics
- https://docs.fedoraproject.org/en-US/quick-docs/configuring-xorg-as-default-gnome-session/

More specifically,
- `pacman -S mesa lib32-mesa vulkan-intel`
- Add `DefaultSession=gnome-xorg.desktop` to the `[daemon]` section of `/etc/gdm/custom.conf`
