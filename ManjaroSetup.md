# Set up Manjaro with Gnome & more, the Arch way

I hate where gnome is going (with a complete disregard for user feedbacks), but I am deeply enchanted by its superior aesthetic. I am totally trapped and screwed. Here is my desperate attempt to make it better, along with some other basic OS configurations.

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
For bluetooth support,
```bash
pacman -S bluez-utils \
          blueman  # this is a nice gui
systemctl enable bluetooth.service
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

## Themes

My themes are composed from a bunch of other established themes with symlinks. See:

- [`~/.local/share/themes`](https://github.com/bryango/cheznous/blob/-/.local/share/themes)
- [`~/.local/share/xdg-data-light`](https://github.com/bryango/cheznous/blob/-/.local/share/xdg-data-light)
- [`~/bin/env-light`](https://github.com/bryango/cheznous/blob/-/bin/env-light)

## Spell check

Fulfill the optional dependencies of `enchant`

```bash
$ pactree --depth=1 --optional=1 enchant | grep -v unresolvable
enchant
├─glib2
├─aspell: for aspell based spell checking support (optional)
├─hunspell: for hunspell based spell checking support (optional)
└─nuspell: for nuspell based spell checking support (optional)

$ pacman -Qe | grep -E 'spell|hyphen'
aspell-en 2020.12.07-1
hunspell-en_us 2020.12.07-4
hyphen-en 2.8.8-5
nuspell 5.1.2-2
```

For more personalized tweaks, see `$DICPATH` in [`~/.profile`](https://github.com/bryango/cheznous/blob/-/.profile) which points to [`~/apps/dicts`](https://github.com/bryango/cheznous/blob/-/apps/dicts). 

## DNS & `resolv{.conf,ed,ed.conf,conf}`

See https://github.com/bryango/chezroot/wiki/DNS.

### check DNS lookup

https://github.com/bryango/technotes/blob/525f3e817e53f78b8dd04431e03becdcabf136a1/Tips.md?plain=1#L176-L178

## firewalld

To me `firewalld` _feels_ like the best choice for modern firewall configurations.

- It _feels_ more powerful than `ufw`
- It works with the next gen `nftables`
- It has nice integrations with NetworkManager
- It has an official GUI
- It has a nice CLI with zsh completions
- It is actively maintained by Fedora / Red Hat

To drop incomings by default,
```bash
sudo firewall-cmd --set-default-zone=drop
```
Further customizations can be found at [`/etc/firewalld`](https://github.com/bryango/chezroot/blob/-/etc/firewalld)

## invalid `$XDG_DATA_DIRS` is catastrophic

An invalid `$XDG_DATA_DIRS` will prevent gnome from starting. See https://wiki.archlinux.org/title/XDG_Base_Directory for the default, and see [`~/.profile`](https://github.com/bryango/cheznous/blob/-/.profile) for my config. The issue is mentioned here:

https://unix.stackexchange.com/questions/471327/whats-the-right-way-to-add-directories-to-xdg-data-dirs
