# Tips and Tricks

## git partial clone

https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/

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

## pacman dependencies

```
pactree
pactree --reverse
```

## make a file immutable

```bash
sudo chattr +i # <file>
```

**Example:** miktex falsely installs `~/.miktex/texmfs/install/tex/latex/jknappen/ubbold.fd`, a problem described here:
> https://tex.stackexchange.com/questions/164299/missing-character-1-in-font-bbold11

To blacklist the file, simply create an empty `ubbold.fd` and then lock it with `chattr +i`. 
