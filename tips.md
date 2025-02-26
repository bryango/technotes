# Tips and Tricks

This is the place to dump various snippets.

## naming conventions

https://en.wikipedia.org/wiki/Naming_convention_(programming)

- use `lowercase` for frequently used items, to minimize <kbd>Shift</kbd> ing
- use `CamelCase` to maximize readability, use `camelCase` if necessary
- prefer `-` over `_`, also to minimize <kbd>Shift</kbd> ing

## monad

https://www.youtube.com/watch?v=ENo_B8CZNRQ

- state can be regarded as functors between functions
- analogy: states in a Hilbert space can be restructed from the operators acting upon it

## bash

- get help: `help mapfile`
- array from **a single line:** `IFS=$'\t' read -r -a outputs <<< "$inputs"`, `-r` for non-escaping
- multiline: `readarray -t array`, `-t` to trim trailing newlines
- directory stack: `pushd` and `popd`, for a temporary `cd`
- use json & jq: `ip -json route show default | jq '.[].gateway' --raw-output`
- available memory: `jc free --mebi | jq '.[] | select( .type == "Mem" ) | .available'`

## git dark magic

- merge without checkout: https://stackoverflow.com/questions/3216360/merge-update-and-pull-git-branches-without-using-checkouts
- delete stale tracking branches: `git branch --remotes --delete origin/stale-branch`
- `git fetch --prune-tags` will prune local tags and imply `--tags` so you probably shouldn't do that

## nix

- builtins.trace
- modules are evaluated recursively until a fixed point
- use github token: `export NIX_CONFIG="access-tokens = github.com=$TOKEN_GITHUB"`

## synology

- global repo: https://payment.synology.com/api/getPackageList.php
- repositories: https://github.com/szyb/synopackage_dotnet/blob/master/src/Synopackage.Model/Config/sources.json

## untimely comments

- I could not reproduce the test failure of `python311Packages.pygls.x86_64-linux` (https://hydra.nixos.org/build/248415117) at aac8dcf368a1d57189c4318579eccd8da2e9be13. Maybe it will disappear after a re-run.
- Before nautilus gtk4 (v43): https://github.com/NixOS/nixpkgs/commit/d618530963a0e1d112c2584e2fc1ae9743cf7b08, which is the parent of https://github.com/NixOS/nixpkgs/pull/182618.

## a study of the nixpkgs pr-tracker

- the main logic:
https://git.qyliss.net/pr-tracker/tree/src/tree.rs?h=bcc2379d5b0debd9cdb2a97d845bf39975540eb1#n55
- the tree of branches:
https://git.qyliss.net/pr-tracker/tree/src/branches.rs?h=bcc2379d5b0debd9cdb2a97d845bf39975540eb1#n11
- the tree is rendered as an html table, beautified via css
  - all children are in fact equivalent: there is no difference between the side branch and the main branch.
  - the apparent main branch is only an artifact of the css rule wrt the `:last-child`
- it does not query hydra at all! It only queries the git repo branches.

## github api

- pr commit:
  - https://api.github.com/repos/NixOS/nixpkgs/pulls/262733
  - https://docs.github.com/en/rest/pulls/pulls#get-a-pull-request
  - a `merged_commit_sha` is available even _before_ the merge! That can be utilized as a convenient rev.
- see if a branch contains: use /compare/...branch.patch


## overleaf github APIs

- `https://www.overleaf.com/user/github-sync/status`
- `https://www.overleaf.com/project/${id}/github-sync/status`
- `https://www.overleaf.com/project/${id}/github-sync/commits/unmerged`

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

## set env

Environment variables can be set non-transparently via dbus: https://eklitzke.org/down-the-ssh-auth-sock-rabbit-hole-a-gnome-adventure

This is a bad idea!

## (n)vim tricks

- correct syntax highlighting for `;` commented config file such as [redshift.conf](https://raw.githubusercontent.com/jonls/redshift/master/redshift.conf.sample): `; vim: ft=dosini`

## rust & cargo

- install rustup from pacman
- lib.rs is functionally equivalent to crates.io, but looks nicer
- install [cargo-binstall](https://lib.rs/crates/cargo-binstall) from pacman
- install [cargo-quickinstall](https://lib.rs/crates/cargo-quickinstall) using binstall

`binstall` & `quickinstall` find and install prebuilt binaries.
What's the difference? I am a bit confused. Maybe `binstall` is for binaries only while `quickinstall` covers libaries as well. One can simply replace `cargo install` with `cargo quickinstall`.

## dedup cargo deps

`cargo tree --duplicates` finds all the duplicated deps with the default features.

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

## editor shenanigans

### `vscode` language server provides `outline`

See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentSymbol

### `atom` > `pulsar`, goodbye `vscode`

I really don't like `vscode`... `pulsar` is a fork of `atom` that works almost perfectly! The binary is available from AUR. I would like to build it from source. Here are some preliminary research:
- https://pulsar-edit.dev/docs/launch-manual/sections/core-hacking/#building-pulsar
- https://github.com/pulsar-edit/pulsar/blob/master/.cirrus.yml
- https://github.com/atom/github/pull/2538: diff with syntax highlighting, a patch that I like

Find the automated build from github:
- go to the release PR
- go to the release commits
- select the one `package.json` that does not contain a version with "-dev"
- download the workflow artifact

See e.g. https://github.com/pulsar-edit/pulsar/actions/runs/6527478252/job/17722380394

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

Optimize PDF: https://askubuntu.com/a/243753
```
ps2pdf -dPDFSETTINGS=/ebook input.pdf output.pdf
```

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

- install optional deps explicitly; eliminate `pacman -Qdttq`
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
- get the URL for the sign-in page and open it in another browser
- get the returned URL and then do a manual redirect to the original sign-in page, using the javascript console

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

### public wifi issues

Sometimes a public wifi captive portal will redirect to an address with no dns record.
I have no idea how this happens, but presumably, this is related to some caching issues.
A workaround is to momentarily connect to some other working hotspot
(e.g., one served from my cell phone) and then reconnect to the public wifi.
This probably flushes the erroneous dns cache.
