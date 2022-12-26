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

`audit` spams dmesg. To exclude unneeded messages, see [`chezroot: /etc/audit/rules.d/quiet.rules`](https://github.com/bryango/chezroot/blob/master/etc/audit/rules.d/quiet.rules)

- To refresh the rules, follow the wiki: https://wiki.archlinux.org/title/Audit_framework. 
- For more on the rules, see: https://man.archlinux.org/man/auditctl.8.en. 

