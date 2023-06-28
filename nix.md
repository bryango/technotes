# Nix: more pacman beyond pacman

Current strategy for package management:

- use nix at the user level, as much as possible
- fall back to pacman & AUR for system / graphical / incompatible packages
- try to migrate `~/bin` to nix packages
- migrate non-secret config from `~/.secrets` to `home.nix`

## limits

- gui apps are often faulty: lack of graphics, theming, audio, input method...
- apps that rely on system bin / lib may have troubles

## intro

- install from pacman, following [the wiki](https://wiki.archlinux.org/title/Nix)
- `profile`: virtual environments, managed with `nix profile`
- `registry`: index of packages (flakes), managed with `nix registry`
- `channels`: _deprecated_, special `profiles` which contain snapshots of the `nixpkgs` repo 

See: https://nixos.org/manual/nix/unstable/package-management/profiles.html

```bash
$ ls -alF --time-style=+ --directory ~/.nix* | sed -E "s/$USER/\$USER/g" 
.nix-channels  ## deprecated, removed
.nix-defexpr/
.nix-profile -> .local/state/nix/profiles/profile/
```

## registry

This is the package index for nix, analogous to that of a traditional package manager such as pacman, but made reproducible via version pinning, just like a modern build system such as cargo. 

```bash
nix registry list

## refresh index & pin (to latest / to hash)
nix registry pin nixpkgs
nix registry add nixpkgs github:NixOS/nixpkgs/dc6263a3028cb06a178c16a0dd11e271752e537b
```

One can also add user repositories:

```bash
nix registry add nixpkgs-config github:bryango/nixpkgs-config
nix registry pin github:bryango/nixpkgs-config
```

Even local ones:

```bash
nix registry add nixpkgs-local $HOME/.config/home-manager/nixpkgs-config
nix registry add nixpkgs-config nixpkgs-local  ## link to local clone
```

## install prebuilt binary

https://hydra.nixos.org/jobset/nixpkgs/trunk/evals

- pick a _finished_ jobset
- search for packages with successful build
- pin nix registry to a nice commit

## dirty quick start

```bash
nix search nixpkgs pulsar
nix profile install nixpkgs#pulsar
  ## --profile "~/.local/state/nix/profiles/$profile"
```

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
nix profile wipe-history --older-than "$num"d

# all-in-one util
nix-collect-garbage  # --delete-older-than, --max-freed, --dry-run
```

To get an overview of package sizes,
```bash
du -h --max-depth=1 /nix/store --exclude=/nix/store/.links | sort -h
```

## binary cache `substituters`

Here we follow the guidance of [**tuna**](https://mirrors.tuna.tsinghua.edu.cn/help/nix/).

- `~/.config/nix/nix.conf`
- [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf)

_Note:_ either `trusted-users` or `trusted-substituters` has to be declared in the root config [`/etc/nix/nix.conf`](https://github.com/bryango/chezroot/blob/-/etc/nix/nix.conf). Otherwise `substituters` will be ignored. This is not emphasized, neither in the manual nor the error message. See https://github.com/NixOS/nix/issues/6672. 

The nixpkgs config (incl. overrides & overlays) is located at `~/.config/nixpkgs/`.

**Update:** the `~/.config/nix**` files are now managed by home-manager at [**cheznix**](https://github.com/bryango/cheznix/blob/-/home.nix).

## _optional:_ `channel`

**Note:** `channel` is deprecated but we can set up a backward compatible layer with the flake registry; see the relevant settings in [**cheznix**](https://github.com/bryango/cheznix/blob/-/home.nix). One can specify:
- `$NIX_PATH`, or
- `--include nixpkgs=channel:$channel`, or
- `-I nixpkgs=flake:$channel`

such that nixpkgs is easily available via `import <nixpkgs> {}`. The list of channels are found in:
- registry: `nix registry list`
- mirror: https://mirrors.tuna.tsinghua.edu.cn/nix-channels/
- upstream: https://nixos.org/channels/

## `profiles`

```bash
$ ls -alF --time-style=+ ~/.local/state/nix/profiles | sed -E "s/$USER/\$USER/g"          
profile -> profile-$gen-link/
profile-$gen-link -> /nix/store/#some-hash
```
- The number `$gen` in `$profile-$gen-link` is the `generation`.
- `profile` is the default user profile

The default system profile, as is documented in [`man nix-env`](https://nixos.org/manual/nix/unstable/command-ref/nix-env.html), is `/nix/var/nix/profiles/default`.

**Note:** the user profiles' location have changed! See https://github.com/NixOS/nix/pull/5226. 
- `/nix/var/nix/profiles/per-user/$USER`: previous default
- `~/.local/state/nix/profiles`: current default

Manual migration might be required for some commands to work properly. 

## old versions, from the binary cache

The guide is here: https://lazamar.github.io/download-specific-package-version-with-nix/. Also we prefer installing the package with binary cache, which is a lot easier than compiling from source.

Here we work with an explicit example: `tectonic-0.12.0` is bundled with `biblatex-3.17`, as of 2023-01-01. The compatible `biber` version is `biber-2.17`. 

- First, check if `biber-2.17` is contained in a recent stable release: https://search.nixos.org/packages. It turns out that we are lucky, as `biber-2.17` is part of the `22.11` release and we can simply install that.

- If we were not able to locate the desired version in a recent stable release, we have to do some git repo archeology. This is aided by the tool
  > https://lazamar.co.uk/nix-versions/
  
  Basically, to install `biber-2.17`, we first locate `biber` in the nixpkgs repo:
  > https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/typesetting/biber/default.nix

  This can also be done locally by inspecting `~/.nix-defexpr/channels/nixpkgs` (this is created in [**cheznix**](https://github.com/bryango/cheznix/blob/-/home.nix) as a symlink to the nixpkgs source). In this case we are slightly unlucky as the `biber` version is not explicit, but rather inherited from `texlive.biber.pkgs`. The `texlive` variable is defined in
  
  > https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix
  
  ... which points us to:
  
  > https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/typesetting/tex/texlive/pkgs.nix

  We can then locate the commit with `biber-2.17`. Check the git tags that contain this commit; the _earliest_ release tag probably contains the desired version (but this is not always guaranteed). 

## packageOverrides example

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

When we invoke `nix-env` these expressions are read locally from `~/.nix-defexpr`, as is documented by:

- https://nixos.org/manual/nix/unstable/command-ref/nix-env.html#files
- https://nixos.org/guides/nix-pills/nix-search-paths.html

With `nix profile`, the expressions are read from the flake registry.
As documented in `plugins/default.nix` and implemented in `wrapper.nix`, this can be achieved with the following `packageOverrides`:
```nix
# home.nix 
nixpkgs.config = {
  packageOverrides = pkgs: with pkgs; {
    gimp-with-plugins = gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    };
  };
};
```
However, this doesn't work out of the box: one needs to override `gimp` to include python2 bindings; see:

- https://github.com/NixOS/nixpkgs/issues/221599
- https://github.com/NixOS/nixpkgs/issues/205742

So the final result is:
```nix
# home.nix 
nixpkgs.config = {
  packageOverrides = pkgs: with pkgs; {
    gimp-with-plugins = gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    };
    gimp = gimp.override {
      withPython = true;
    };
  };
};
```

## shell profile

One should probably have an `export` here at: https://github.com/NixOS/nix/blob/master/scripts/nix-profile-daemon.sh.in#L3

## note on transition to nix flake

`nix flake` is the future, and one should replace `nix-env` with `nix profile` which is based on flake. However, as of March 2023 the documentation is so poorly written that it is very hard to perform a smooth transition.

**Update:** although the documentations are sparse and scattered, I tried to consult Bing Chat AI and it seems to generate some very useful instructions! In particular, it tells me that `nix-channel` is replaced by `nix registry`.

**Update:** I've transitioned my packages setup to `home-manager` with flake. To be documented!
