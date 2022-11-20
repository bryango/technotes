# Tips and Tricks

## git partial clone

https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/

```
git clone --filter=blob:non
```

## dconf

Check `dconf help`

```
dconf dump / > dconf-dump.conf
# tweak the dumped file
dconf load / < dconf-dump.conf
```

## pacman dependencies

```
pactree
pactree --reverse
```
