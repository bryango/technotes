# Tips and Tricks

This is the place to dump various snippets.

## naming conventions

https://en.wikipedia.org/wiki/Naming_convention_(programming)

- use `lowercase` for frequently used items, to minize <kbd>Shift</kbd> ing
- use `CamelCase` to maximize readability, use `camelCase` if necessary
- prefer `-` over `_`, also to minize <kbd>Shift</kbd> ing

## latex `\skew` accent

e.g. `\skew{4}{\bar}{j}`. Compare:

$$ j \wedge \bar{j} \qquad\textit{vs.}\qquad j \wedge \skew{4}{\bar}{j} $$

## upstream renaming & downstream symlinking

I want to rename `~/apps/Mathematica` to `~/apps/wolfram`. To find all the symlinks pointing at `~/apps/Mathematica`,
```bash
$ fd --hidden --no-ignore --type=symlink --list-details | grep Mathematica | grep -v aur-mathematica | sed -E "s|$USER|\$USER|g"
lrwxrwxrwx 1 $USER $USER  31 11月30日 10:38 ./apps/Mathematica/Applications -> ../../.Mathematica/Applications
lrwxrwxrwx 1 $USER $USER  43 12月28日 10:29 ./docs/archive/ThermalFieldTheory2020/thermal5/plots/MathUtils.wl -> ../../../Templates/Mathematica/MathUtils.wl
lrwxrwxrwx 1 $USER $USER  18 11月30日 10:42 ./.Mathematica/Applications/diffgeo.m -> diffgeoM/diffgeo.m
lrwxrwxrwx 1 $USER $USER  31 11月30日 10:39 ./.Mathematica/Applications/diffgeoM -> ../../apps/Mathematica/diffgeoM
lrwxrwxrwx 1 $USER $USER  30 11月30日 10:40 ./.Mathematica/Applications/Physica -> ../../apps/Mathematica/Physica
lrwxrwxrwx 1 $USER $USER  33 11月30日 10:40 ./.Mathematica/Applications/Spelunking -> ../../apps/Mathematica/Spelunking
lrwxrwxrwx 1 $USER $USER  27  3月12日 18:19 ./.Mathematica/Applications/xAct -> ../../apps/Mathematica/xAct
lrwxrwxrwx 1 $USER $USER  33 11月30日 10:41 ./.Mathematica/Autoload/FrontEnd/init.m -> ../../Applications/Physica/init.m
```
I need only fix the links within `~/.Mathematica/Applications/` using `ln -sf`. Done!

## reset qt theming

`unset QT_QPA_PLATFORMTHEME`

## flatpak

Don't use flatpaks, unless you intend to use many of them. The reason is that the runtimes are HUGE. However, if you install many flatpak apps then the runtimes are shared between apps, so the size issue is averaged out. 

- cleanup: https://github.com/flatpak/flatpak/issues/3542.
- mirror: https://github.com/flathub/flathub/issues/813#issuecomment-753815626. 

## `pushd` and `popd`

Temporary `cd` by pushing the target into a directory stack, then return to the previous directory by poping it.

## `djvu -> pdf`

```bash
djvups input.djvu | ps2pdf - output.pdf
```
See: https://superuser.com/questions/100572/how-do-i-convert-a-djvu-document-to-pdf-in-linux-using-only-command-line-tools/1194757#1194757. 

## git partial clone

See https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/

```bash
git clone --filter=blob:none # --single-branch --branch=...
git submodule update --init --filter=blob:none --recursive
```

## gitignore

```gitignore
# ignore itself so it will not be committed
/.gitignore
# ... so one does not have to go to `.git/info/exclude`
```

## dconf

Check `dconf help`

```bash
dconf dump / > dconf-dump.conf

# tweak the dumped file
dconf load / < dconf-dump.conf
```

## pacman
Management strategies:

- install optional deps explicitly
- know all explicitly installed packages
- `pacman -Qe` `>` [`~/backup/pacman/explicit.log`](https://github.com/bryango/cheznous/blob/-/backup/pacman/explicit.log)
- `pacman -Q` `>` [`~/backup/pacman/all.log`](https://github.com/bryango/cheznous/blob/-/backup/pacman/all.log)

### check dependencies

```bash
pactree --color --sync # for sync database
              # --optional=0
              # --depth=1
pactree --color --reverse # for packages that depends on it
```

### obtain pgp key

```bash
gpg --recv-key
```

## make a file immutable

```bash
sudo chattr +i # <file>
```

## tailscale setup

See e.g. https://tailscale.com/kb/1103/exit-nodes/

```bash
sudo tailscale up --advertise-exit-node \
                  --accept-routes
                # --exit-node=...  ## find in `tailscale status`
                # --advertise-routes=...
```

## firefox google sign-in

I cannot sign in with my google account on firefox. I cannot figure out why. However, there is a workaround:
- get the URL for the sign-in page and open it in another brower
- get the returned URL and then do a manual redirect in the original sign-in page, using the javascript console

```js
window.location.replace("...")
```
The sign-in should proceed with no issue!

## dmesg: no audits

`audit` spams dmesg. To exclude unneeded messages, see [`/etc/audit/rules.d/quiet.rules`](https://github.com/bryango/chezroot/blob/-/etc/audit/rules.d/quiet.rules)

- To refresh the rules, follow the wiki: https://wiki.archlinux.org/title/Audit_framework. 
- For more on the rules, see: https://man.archlinux.org/man/auditctl.8.en. 

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

## /etc/resolv.conf

Apps like `tailscale` will attempt to write to `/etc/resolv.conf` which results in conflicts. `resolvconf` is an interface (standard?) to manage `/etc/resolv.conf`. Unsurprisingly, systemd has a built-in `resolvconf`. To make use of that,

- `systemctl enable --now systemd-resolved`
- `ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
- finally, install `systemd-resolvconf` (must do this at the very last)

See [**chezroot: 67e84a9**](https://github.com/bryango/chezroot/commit/67e84a9) for more information.
The symlink tells NetworkManager to give control of `/etc/resolv.conf` to systemd. This is the default behavior built in Arch but this may differ in other distros. If the app, in this case `tailscale`, fails to pick up the change, then stop `systemd-resolved` `NetworkManager` `tailscaled` and restart each of them in sequence.

## invalid `$XDG_DATA_DIRS` is catastrophic

An invalid `$XDG_DATA_DIRS` will prevent gnome from starting. See https://wiki.archlinux.org/title/XDG_Base_Directory for the default, and see [`~/.profile`](https://github.com/bryango/cheznous/blob/-/.profile) for my config. The issue is mentioned here:

https://unix.stackexchange.com/questions/471327/whats-the-right-way-to-add-directories-to-xdg-data-dirs
