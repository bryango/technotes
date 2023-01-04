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

**Edit:** `DefaultSession` doesn't seem to work. Fortunately, pick Xorg once and it seems that GDM will remember it.

## Trackers

I really hate them!
```
systemctl --user mask tracker-miner-fs-3.service
```
Edit `~/.config/autostart/tracker-miner-fs-3.desktop`
```desktop
[Desktop Entry]
Name=Tracker File System Miner
## ...
## ignore some lines
## add the following lines:
## >>>
X-GNOME-Autostart-enabled=false
X-GNOME-HiddenUnderSystemd=true
Hidden=true
```
It seems that this is enough. <br>
For a more extreme measure, see https://gist.github.com/vancluever/d34b41eb77e6d077887c

## Color profile

The automatic color profile is weirdly purple on my laptop. `sRGB` seems to be the right one. Note that for the new profile to take effect, some apps (including firefox) need to be restarted. 

## Terminals

Default terminal emulators are hard coded in glib ([#338](https://gitlab.gnome.org/GNOME/glib/-/issues/338)). These are the terminals that gnome uses to open the `.desktop` files (those including the setting `Terminal=true`), among other things. I've hence created a default terminal wrapper for tilix to fool glib; see [`~/bin/x-terminal-emulator`](https://github.com/bryango/cheznous/blob/-/bin/x-terminal-emulator). For it to work, symlink:

```bash
gnome-terminal -> xdg-terminal-exec -> x-terminal-emulator
```

Eventually the symlink for `gnome-terminal` will no longer be necessary, as `xdg-terminal-exec` becomes standard for glib 2.75; see [`glib:22e1b9b`](https://github.com/GNOME/glib/commit/22e1b9bcc0ca7cd1ba2457ddf5b5545752f9c7ea). See also the links to the glib repo in [`x-terminal-emulator`](https://github.com/bryango/cheznous/blob/-/bin/x-terminal-emulator) for more details. 

## Input method: `fcitx5`

Version 5 of fcitx is great! Install with the meta package `manjaro-asian-input-support-fcitx5`

```bash
$ pacman -Qe | grep fcitx | sort -r
manjaro-asian-input-support-fcitx5 2022.04-1
fcitx5-chinese-addons 5.0.16-1

$ pactree --depth=1 manjaro-asian-input-support-fcitx5  
manjaro-asian-input-support-fcitx5
├─fcitx5-qt
├─fcitx5-gtk
└─fcitx5-configtool
```

The default input panel looks horrible, but don't worry. Install the [gnome-shell kimpanel extension](https://extensions.gnome.org/extension/261/kimpanel/) and we are good to go!
