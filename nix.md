# Nix: misc notes

Probably outdated; see some updated notes at [**cheznix**](https://github.com/bryango/cheznix).

## issues

- shell profile: one should probably have an `export` here at: https://github.com/NixOS/nix/blob/master/scripts/nix-profile-daemon.sh.in#L3

- https://github.com/NixOS/nixpkgs/issues/199162: `replaceDependency` is awesome but broken in pure mode

## on transition to nix flake

`nix flake` is the future, and one should replace `nix-env` with `nix profile` which is based on flake. However, as of March 2023 the documentation is so poorly written that it is very hard to perform a smooth transition.

**Update:** although the documentations are sparse and scattered, I tried to consult Bing Chat AI and it seems to generate some very useful instructions! In particular, it tells me that `nix-channel` is replaced by `nix registry`.

**Update:** I've transitioned my packages setup to `home-manager` with flake. To be documented!

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

## old versions, from the binary cache (outdated)

**Outdated;** see [**cheznix**](https://github.com/bryango/cheznix).

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
