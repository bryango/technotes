# Nix: more pacman beyond pacman

- install from pacman, following [the wiki](https://wiki.archlinux.org/title/Nix)
- `profiles` are like virtual environments, managed with `nix-env`
- `channels` are managed as special `profiles`; they are snapshots of the package repo

See: https://nixos.org/manual/nix/unstable/package-management/profiles.html

```bash
$ ls -alF --time-style=+ --directory .nix* | sed -E "s/$USER/\$USER/g" 
-rw-r--r-- 1 $USER $USER 75  .nix-channels
drwxr-xr-x 1 $USER $USER 42  .nix-defexpr/
lrwxrwxrwx 1 $USER $USER 44  .nix-profile -> /nix/var/nix/profiles/per-user/$USER/profile/
```

## quick start

```bash
nix-env -v \
  --profile "/nix/var/nix/profiles/per-user/$USER/$profile" \
  --file "channel:$channel" \
  --install --prebuilt-only --attr # -ibA, or: --query, --dry-run, ...
```

- `file` is the `expression` to use for the package build (`derivation`). It defaults to `~/.nix-defexpr`.
- `~/.nix-defexpr` in turn defaults to the channel set up by `nix-channel`.

```bash
$ ls -alF --time-style=+ .nix-defexpr | sed -E "s/$USER/\$USER/g"  
total 8
drwxr-xr-x 1 $USER $USER   42  ./
drwx------ 1 $USER $USER 1500  ../
lrwxrwxrwx 1 $USER $USER   45  channels -> /nix/var/nix/profiles/per-user/$USER/channels/
lrwxrwxrwx 1 $USER $USER   44  channels_root -> /nix/var/nix/profiles/per-user/root/channels
```

One can specify the expression / channel manually, with `-f "channel:$channel"`. The list of channels are found in:
- mirror: https://mirrors.tuna.tsinghua.edu.cn/nix-channels/
- upstream: https://nixos.org/channels/

## garbage collection

See https://nixos.org/manual/nix/unstable/package-management/garbage-collection.html.

```bash
# check access points (roots)
nix-store --gc --print-roots

# actual garbage collection
nix-store -v --gc

# further optimisation
nix-store --optimise
```

More AGRESSIVE:

```bash
# delete old generations
nix-env -p "$profile" --delete-generations old  # or, specify $gen

# all-in-one util
nix-collect-garbage  # --delete-older-than, --max-freed, --dry-run
```

To get an overview of package sizes,
```bash
du -h --max-depth=1 /nix/store --exclude=/nix/store/.links | sort -h
```

## binary cache `substituters`

Here we follow the guidance of [**tuna**](https://mirrors.tuna.tsinghua.edu.cn/help/nix/).

- [`~/.config/nix/nix.conf`](https://github.com/bryango/cheznous/blob/-/.config/nix/nix.conf)
- [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf)

_Note:_ either `trusted-users` or `trusted-substituters` has to be declared in the root config [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf). Otherwise `substituters` will be ignored. This is not emphasized, neither in the manual nor the error message. See https://github.com/NixOS/nix/issues/6672. 

## _optional:_ `channel`

**Note:** one does **_not_** have to set up a `channel` to install packages. One can then install packages without keeping the `channel` cache; use `nix-env -f` as shown before in the _quick start_ section.

```bash
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable
nix-channel -v --update
```

- Channels are managed just like profiles. Each `--update` creates a `generation` for easy `rollback`
- Channels are sets of `expressions`, or functions
- Package building is doing `derivations`, i.e. acting `expressions` onto some inputs

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

**Note:** The default _per-user_ profile is `per-user/"$USER"/profile`.
- This is documented in [`man nix3-profile`](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-profile.html)
- ... but _not_ documented in [`man nix-env`](https://nixos.org/manual/nix/unstable/command-ref/nix-env.html)

However this is indeed the default _per-user_ profile. The default system profile, as is documented in [`man nix-env`](https://nixos.org/manual/nix/unstable/command-ref/nix-env.html), is `/nix/var/nix/profiles/default`

## install old packages

The guide is here: https://lazamar.github.io/download-specific-package-version-with-nix/. Also we prefer installing the package with binary cache, which is a lot easier than compiling from source.

Here we work with an explicit example: `tectonic-0.12.0` is bundled with `biblatex-3.17`, as of 2023-01-01. The compatible `biber` version is `biber-2.17`. 

- First, check if `biber-2.17` is contained in a recent release: https://search.nixos.org/packages. It turns out that we are lucky, as `biber-2.17` is part of the `22.11` and `unstable` release and we can simply install that with:

```bash
nix-env --profile "/nix/var/nix/profiles/per-user/$USER/biber-2.17" \
        -ibA nixpkgs.biber # -f channel:nixos-22.11
```

- If we were not able to locate the desired version in a recent release, we have to do some git repo archeology. This is helped by the tool https://lazamar.co.uk/nix-versions/. Basically, to install `biber-2.17`, we first locate it in the nixpkgs repo:

  > https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/typesetting/biber/default.nix

  In this case we are slightly unlucky as the `biber` version is not explicit, but inherited from `texlive.biber.pkgs`. 

