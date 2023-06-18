# Nix: more pacman beyond pacman

Current strategy for package management:

- use nix at the user level, as much as possible
- fall back to pacman & AUR for system / incompatible packages
- try to avoid `~/bin` for packages

## intro

- install from pacman, following [the wiki](https://wiki.archlinux.org/title/Nix)
- `profiles` are like virtual environments, managed with `nix-env` $\to$ `nix profile` for the new interface
- `channels` are managed as special `profiles`; they are snapshots of the package repo $\to$ `nix registry`

See: https://nixos.org/manual/nix/unstable/package-management/profiles.html

```bash
$ ls -alF --time-style=+ --directory .nix* | sed -E "s/$USER/\$USER/g" 
-rw-r--r-- 1 $USER $USER 75  .nix-channels
drwxr-xr-x 1 $USER $USER 16  .nix-defexpr/
lrwxrwxrwx 1 $USER $USER 45  .nix-profile -> /home/$USER/.local/state/nix/profiles/profile/
```

Note: the profiles' location have changed! See https://github.com/NixOS/nix/pull/5226. 
- `/nix/var/nix/profiles/per-user/$USER`: previous default
- `~/.local/state/nix/profiles`: current default

Manual migration might be required for commands such as `nix-channel` to work properly. For now I have:
- `/nix/var/nix/profiles/per-user/$USER/channels` $\to$ `~/.local/state/nix/profiles`

## ongoing transition to nix flake

`nix flake` is the future, and one should replace `nix-env` with `nix profile` which is based on flake. However, as of March 2023 the documentation is so poorly written that it is very hard to perform a smooth transition.

**Update:** although the documentations are sparse and scattered, I tried to consult Bing Chat AI and it seems to generate some very useful instructions! In particular, it tells me that `nix-channel` is replaced by `nix registry`.

**Update:** I've transitioned my packages setup to `home-manager` with flake. To be documented!

## flake registry

```bash
nix registry list
nix registry pin nixpkgs  ## refresh package cache
nix registry add nixpkgs github:NixOS/nixpkgs/dc6263a3028cb06a178c16a0dd11e271752e537b  ## pin to commit hash
```

## install prebuilt binary

https://hydra.nixos.org/jobset/nixpkgs/trunk/evals

- pick a _finished_ jobset
- search for packages with successful build
- pin nix registry to a nice commit

## dirty quick start

```bash
nix-env -v \
  --profile "/nix/var/nix/profiles/per-user/$USER/$profile" \
  --file "channel:$channel" \
  --install --prebuilt-only --attr # -ibA, or: --query, --dry-run, ...
```

- `file` is the `expression` to use for the package build (`derivation`). It defaults to `~/.nix-defexpr`.
- `~/.nix-defexpr` in turn defaults to the channel set up by `nix-channel`.

```bash
$ ls -alF --time-style=+ ~/.nix-defexpr | sed -E "s/$USER/\$USER/g"  
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

The nixpkgs config (incl. overrides & overlays) is located at:

- [`~/.config/nixpkgs/`](https://github.com/bryango/cheznous/blob/-/.config/nixpkgs)

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

## install old versions, from the binary cache

The guide is here: https://lazamar.github.io/download-specific-package-version-with-nix/. Also we prefer installing the package with binary cache, which is a lot easier than compiling from source.

Here we work with an explicit example: `tectonic-0.12.0` is bundled with `biblatex-3.17`, as of 2023-01-01. The compatible `biber` version is `biber-2.17`. 

- First, check if `biber-2.17` is contained in a recent stable release: https://search.nixos.org/packages. It turns out that we are lucky, as `biber-2.17` is part of the `22.11` release and we can simply install that with:

```bash
nix-env --profile "/nix/var/nix/profiles/per-user/$USER/biber-2.17" \
        --file https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-22.11/nixexprs.tar.xz \ 
        -ibA biber
```

- If we were not able to locate the desired version in a recent stable release, we have to do some git repo archeology. This is aided by the tool
  > https://lazamar.co.uk/nix-versions/
  
  Basically, to install `biber-2.17`, we first locate `biber` in the nixpkgs repo:
  > https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/typesetting/biber/default.nix

  This can also be done locally by inspecting `~/.nix-defexpr/channels/nixpkgs`. In this case we are slightly unlucky as the `biber` version is not explicit, but rather inherited from `texlive.biber.pkgs`. The `texlive` variable is defined in
  
  > https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix
  
  ... which points us to:
  
  > https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/typesetting/tex/texlive/pkgs.nix

  We can then locate the commit with `biber-2.17`. Check the git tags that contain this commit; the _earliest_ release tag probably contains the desired version (but this is not always guaranteed). 

## packageOverrides

Sometimes we need to overwrite some default behavior of packages. The guides are here:

- overlays: https://nixos.wiki/wiki/Overlays
- overrides: https://nixos.org/guides/nix-pills/nixpkgs-overriding-packages.html

For declarative package managements, see:
- https://nixos.wiki/wiki/FAQ#How_can_I_manage_software_with_nix-env_like_with_configuration.nix.3F
- https://nixos.org/manual/nixpkgs/stable/#sec-declarative-package-management
- https://github.com/knedlsepp/nix-cheatsheet/blob/master/examples/nixpkgs-config.nix/declarative-user-environments/config.nix

Again we work with an explicit example: I want to install `gimp` with a single plugin: `resynthesizer`. This is achieved with the meta package `gimp-with-plugins`, according to:

- meta wrapper: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/graphics/gimp/wrapper.nix
- actual plugins: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/graphics/gimp/plugins/default.nix

When we invoke `nix-env` locally, these expressions are read locally from `~/.nix-defexpr`, as is documented by:

- https://nixos.org/manual/nix/unstable/command-ref/nix-env.html#files
- https://nixos.org/guides/nix-pills/nix-search-paths.html

As documented in `plugins/default.nix` and implemented in `wrapper.nix`, this can be achieved with the following `packageOverrides`:
```nix
# cat ~/.config/nixpkgs/config.nix 
{
  packageOverrides = pkgs: with pkgs; {
    gimp-with-plugins = gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    };
  };
}
```
However, this doesn't work out of the box: one needs to override `gimp` to include python2 bindings; see:

- https://github.com/NixOS/nixpkgs/issues/221599
- https://github.com/NixOS/nixpkgs/issues/205742

So the final result is:
```nix
# cat ~/.config/nixpkgs/config.nix 
{
  packageOverrides = pkgs: with pkgs; {
    gimp-with-plugins = gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    };
    gimp = gimp.override {
      withPython = true;
    };
  };
}
```
One can then complete the installation with `nix-env -iA nixpkgs.gimp-with-plugins`. Note that `nix-env -ibA` may fail silently because there is no binary cache of gimp where `withPython = true`, so a local rebuild is required.

## shell profile

One should probably have an `export` here at: https://github.com/NixOS/nix/blob/master/scripts/nix-profile-daemon.sh.in#L3
