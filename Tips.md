# Tips and Tricks

This is the place to dump various snippets.

## naming conventions

https://en.wikipedia.org/wiki/Naming_convention_(programming)

- use `lowercase` for frequently used items, to minize <kbd>Shift</kbd> ing
- use `CamelCase` to maximize readability, use `camelCase` if necessary
- prefer `-` over `_`, also to minize <kbd>Shift</kbd> ing

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

An invalid `$XDG_DATA_DIRS` will prevent gnome from starting. See https://wiki.archlinux.org/title/XDG_Base_Directory for the default, and see [`~/.profile`](https://github.com/bryango/cheznous/blob/-/.profile) for my config.
