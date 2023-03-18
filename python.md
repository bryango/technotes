# [A World without Pythons would be so Simple](https://arxiv.org/abs/2102.07774)

## package management

There are many ways to manage python packages. My principles:

- when the dependencies are managable, trust the system: `pacman -S pipx`
- when used as general utils (python agnostic), try pipx:  `pipx install poetry`
- for scientific / interactive project, use `mamba` (conda). See also [**MambaCadabra.md**](./MambaCadabra.md).
- whenever possible, avoid `pip`!

The issue with pip is that it pollutes the environment. If that's okay or you are in a throw-away virtualenv, then _do_ use pip because it's much more efficient than mamba (conda).

## pip & conda skeleton

- always use `pip` in a virtual environment! In such cases, never use `--user`!
- when thinking about `pip --user` try to use `pipx` instead!

It is easy to convert `pip` to `conda` packages:

- https://www.anaconda.com/blog/using-pip-in-a-conda-environment
- https://docs.conda.io/projects/conda-build/en/latest/user-guide/tutorials/build-pkgs-skeleton.html
- https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html

e.g. [`nbopen.meta.yaml`](./nbopen.meta.yaml) is created with

```
conda skeleton pypi nbopen
```
> There is a bug in `libmamba` such that the build crashes when using custom channel mirrors; a workaround is found in https://github.com/mamba-org/boa/issues/213#issuecomment-1474621395.

`conda skeleton` generates a `meta.yaml` that is almost usable; some tweaks are manually added, this includes the following:
- critical fix: https://github.com/bryango/technotes/blob/45b6d900177e33c103e97c52e32c31bd16537776/nbopen.meta.yaml#L24
- nice improvement: https://github.com/bryango/technotes/blob/45b6d900177e33c103e97c52e32c31bd16537776/nbopen.meta.yaml#L17

After that we get a nice little conda package to install: `mamba install --use-local nbopen`.

## shell completions

- `poetry completions zsh` > [`~/.zsh_profiles/completions/_poetry`](https://github.com/bryango/zsh-profiles/blob/-/completions/_poetry)
- zshrc: `compdef mamba=conda` after `conda-setup`
