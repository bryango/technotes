# Nix: more pacman beyond pacman

- install from pacman, following [the wiki](https://wiki.archlinux.org/title/Nix)
- `profiles` are like virtual environments, managed with `nix-env`
- `channels` are special `profiles`; they are snapshots of the package repo

See: https://nixos.org/manual/nix/unstable/package-management/profiles.html

```bash
$ ls -alF --time-style=+ --directory .nix* | sed -E "s/$USER/\$USER/g" 
-rw-r--r-- 1 $USER $USER 75  .nix-channels
drwxr-xr-x 1 $USER $USER 42  .nix-defexpr/
lrwxrwxrwx 1 $USER $USER 44  .nix-profile -> /nix/var/nix/profiles/per-user/$USER/profile/
```

## binary cache `substituters`

Here we follow the guidance of [**tuna**](https://mirrors.tuna.tsinghua.edu.cn/help/nix/).

- [`~/.config/nix/nix.conf`](https://github.com/bryango/cheznous/blob/-/.config/nix/nix.conf)
- [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf)

_Note:_ either `trusted-users` or `trusted-substituters` has to be declared in the root config [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf). Otherwise `substituters` will be ignored. This is not emphasized, neither in the manual nor the error message. See https://github.com/NixOS/nix/issues/6672. 

## _optional:_ `channel`

**Note:** one does **_not_** have to set up a `channel` to install packages. See later sections.

```bash
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable

# more channels: https://mirrors.tuna.tsinghua.edu.cn/nix-channels/
# .... upstream: https://nixos.org/channels/

nix-channel -v --update
```

Channels are managed just like profiles. Each `--update` creates a `generation` for easy `rollback`.

## `profiles`

```bash
$ ls -alF --time-style=+ /nix/var/nix/profiles/per-user/"$USER" | sed -E "s/$USER/\$USER/g"          
total 20
drwxr-xr-x 1 $USER root  118  ./
drwxr-xr-x 1 root  root   18  ../
lrwxrwxrwx 1 $USER $USER  15  channels -> channels-2-link/
lrwxrwxrwx 1 $USER $USER  60  channels-1-link -> /nix/store/#some-hash
lrwxrwxrwx 1 $USER $USER  60  channels-2-link -> /nix/store/#some-hash
lrwxrwxrwx 1 $USER $USER  14  profile -> profile-1-link/
lrwxrwxrwx 1 $USER $USER  60  profile-1-link -> /nix/store/#some-hash
```
- The number `$gen` in `$profile-$gen-link` is the `generation`.
- `channel` is the channel profile
- `profile` is the default user profile
