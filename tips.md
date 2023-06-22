# Tips and Tricks

This is the place to dump various snippets.

## naming conventions

https://en.wikipedia.org/wiki/Naming_convention_(programming)

- use `lowercase` for frequently used items, to minize <kbd>Shift</kbd> ing
- use `CamelCase` to maximize readability, use `camelCase` if necessary
- prefer `-` over `_`, also to minize <kbd>Shift</kbd> ing

## bash builtins

- array: `IFS=$'\t' read -r -a outputs <<< "$inputs"`, `-r` for non-escaping
- directory stack: `pushd` and `popd`, for a temporary `cd`

## nix functions

- builtins.trace
- modules are evaluated recursively until a fixed point

## python oneliners

- [copy files](https://stackoverflow.com/questions/123198/how-to-copy-files): `shutils.copy2`
- [access nested dict](https://stackoverflow.com/a/14692747): `functools.reduce(operator.getitem, key_sequence, data_dict)`
- [currying](https://docs.python.org/3/library/functools.html#functools.partial): `functools.partial`
- [static method](https://docs.python.org/3/library/functions.html#staticmethod): `@staticmethod`
- [generic function](https://docs.python.org/3/library/functools.html#functools.singledispatch): `@functools.singledispatch`
- [is instance of class / type](https://docs.python.org/3/library/functions.html#isinstance): `isinstance`

Stuff:
- https://stackoverflow.com/questions/53845024/defining-a-recursive-type-hint-in-python
- https://peps.python.org/pep-3102/
- https://peps.python.org/pep-0484/#forward-references

## (n)vim tricks

- correct syntax highlighting for `;` commented config file such as [redshift.conf](https://raw.githubusercontent.com/jonls/redshift/master/redshift.conf.sample): `; vim: ft=dosini`

## rust & cargo

- install rustup from pacman
- lib.rs is functionally equivalent to crates.io, but looks nicer
- install [cargo-binstall](https://lib.rs/crates/cargo-binstall) from pacman
- install [cargo-quickinstall](https://lib.rs/crates/cargo-quickinstall) using binstall

`binstall` & `quickinstall` find and install prebuilt binaries.
What's the difference? I am a bit confused. Maybe `binstall` is for binaries only while `quickinstall` covers libaries as well. One can simply replace `cargo install` with `cargo quickinstall`.

## wine wechat high cpu usage

The offending process is `WeChatAppEx.exe`, this is related to 小程序.
- https://bbs.kanxue.com/thread-276281.htm
- https://bbs.kanxue.com/thread-275034.htm

The executables are located under `/home/$USER/.deepinwine/Deepin-WeChat/drive_c/users/$USER/Application\ Data/Tencent/WeChat/XPlugin/Plugins/*WMPF*`. Removing the directories does not work, as they will be recreated when wechat is restarted. So I did:

```bash
chmod a-x WeChatAppEx.exe
chmod a-r WeChatAppEx.exe 
sudo chattr +i WeChatAppEx.exe 
```
We'll see.

## chezmoi forget deleted files

- reveal the deleted files in the git tree by `chezmoi status`
- run `chezmoi forget` on the targets

## literal `\t` in terminal

press `ctrl-v` and then hit `tab`!

## shadowsocks uri scheme

https://github.com/shadowsocks/shadowsocks-org/wiki/SIP002-URI-Scheme

The `userinfo` field is base64 encoded with javascript `btoa()`. It seems that this is required by the _outline_ app. `btoa()` may fail if `password` contains non-ascii characters, so don't do that!

```javascript
function ssuri(method, password, hostname, port, tag) {
  const userinfo = btoa(method + ":" + password)
  return `ss://${userinfo}@${hostname}:${port}/#${tag}`
} 
```

## play a simple sound from the terminal

https://unix.stackexchange.com/questions/681289/play-sound-when-command-finishes

`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`

## list all (listening) ports

`ss -tunlp`
- `-t` shows TCP ports.
- `-u` shows UDP ports.
- `-n` shows numerical addresses instead of resolving hosts.
- `-l` shows only listening ports.
- `-p` shows the PID and name of the listener’s process.
- `-a` shows all connections, not just the listening ones.

`netstat` is deprecated and `ss` is the sucessor.
- https://wiki.archlinux.org/title/Network_configuration#Investigate_sockets
- https://archlinux.org/news/deprecation-of-net-tools

## `vscode` shenanigans

### language server provides `outline`

See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentSymbol

### `atom` > `pulsar`, goodbye `vscode`

I really don't like `vscode`... `pulsar` is a fork of `atom` that works almost perfect! The binary is available from AUR. I would like to build it from source. Here are some preliminary research:
- https://pulsar-edit.dev/docs/launch-manual/sections/core-hacking/#building-pulsar
- https://github.com/pulsar-edit/pulsar/blob/master/.cirrus.yml
- https://github.com/atom/github/pull/2538: diff with syntax highlighting, a patch that I like

## latex `\skew` accent

e.g. `\skew{4}{\bar}{j}`. Compare:

$$ j \wedge \bar{j} \qquad\textit{vs.}\qquad j \wedge \skew{4}{\bar}{j} $$

See: https://tex.stackexchange.com/questions/4192/bad-positioning-of-math-accents-for-the-beamer-standard-font

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

`unset QT_QPA_PLATFORMTHEME`; see [**cheznous:** `~/bin/env-light`](https://github.com/bryango/cheznous/blob/-/bin/env-light)

## flatpak

Don't use flatpaks, unless you intend to use many of them. The reason is that the runtimes are HUGE. However, if you install many flatpak apps then the runtimes are shared between apps, so the size issue is averaged out. 

- cleanup: https://github.com/flatpak/flatpak/issues/3542.
- mirror: https://github.com/flathub/flathub/issues/813#issuecomment-753815626. 

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

## dns lookup

See:
- https://wiki.archlinux.org/title/Domain_name_resolution#Name_Service_Switch
- https://wiki.archlinux.org/title/Domain_name_resolution#Lookup_utilities

Basically,
- resolve using system dns (NSS): `getent hosts`
- resolve with a given server: `drill @nameserver`

`dig` seems to be the traditional utility, but `drill` is usually built in:
```bash
$ which drill | pacman -Qo -
/usr/bin/drill is owned by ldns 1.8.3-2

$ pactree --reverse ldns --depth=1
ldns
└─openssh
```