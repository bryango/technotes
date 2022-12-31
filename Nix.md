## nix

- install from pacman, following [the wiki](https://wiki.archlinux.org/title/Nix)
- `profiles` are like virtual environments, managed with `nix-env`
- `channels` are special `profiles`; they are snapshots of the package repo
- see: https://nixos.org/manual/nix/unstable/package-management/profiles.html

```bash
$ ls -alF --time-style=+ --directory .nix* | sed -E "s/$USER/\$USER/g" 
-rw-r--r-- 1 $USER $USER 75  .nix-channels
drwxr-xr-x 1 $USER $USER 42  .nix-defexpr/
lrwxrwxrwx 1 $USER $USER 44  .nix-profile -> /nix/var/nix/profiles/per-user/$USER/profile/
```

### nix mirrors

- set up `channel`, following [**tuna**](https://mirrors.tuna.tsinghua.edu.cn/help/nix/). 

```bash
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable
# more channels: https://mirrors.tuna.tsinghua.edu.cn/nix-channels/
# .... upstream: https://nixos.org/channels/

nix-channel -v --update
```

- binary cache `substituters`, see:

  - [`~/.config/nix/nix.conf`](https://github.com/bryango/cheznous/blob/-/.config/nix/nix.conf)
  - [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf)

**Note:** either `trusted-users` or `trusted-substituters` has to be declared in the root config [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf). Otherwise `substituters` will be ignored.
