# [A World without Pythons would be so Simple](https://arxiv.org/abs/2102.07774)

Some notes on python environment protection. See also:
- https://bitecode.substack.com/p/why-not-tell-people-to-simply-use?
- https://github.com/mitsuhiko/rye

## python runtimes

This can be managed by mamba or [rtx](https://github.com/jdxcode/rtx).
I've chosen rtx for now.

## package management

There are many ways to manage python packages. My principles:

- when the dependencies are managable, trust the system: `pacman -S pipx`
- when used as general utils (environment agnostic), try pipx:  `pipx install poetry`
- for scientific / interactive project, use `mamba` (conda). See also [**MambaCadabra.md**](./MambaCadabra.md).
- whenever possible, avoid `pip`!

The issue with pip is that it pollutes the environment. If that's okay or you are in a throw-away virtualenv, then _do_ use pip because it's much more efficient than mamba (conda).

`pip` is more of a package _installer_ than a package _manager_. It cares little about dependency resolution & environmental protection. On the other hand, `mamba` (conda) is a full-fledged package manager, albeit an extremely slow one.

## pipx inject dependencies

For example, to install the ruff suite:
```bash
pipx install ruff-lsp
pipx inject --include-apps ruff-lsp ruff
pipx inject --include-apps ruff-lsp flake8-to-ruff
```

## language server

The one built into vscode is `pylance` but the hint is not very readable.
This feels worse than what I remember, back in the days of atom.
I would like to test:
- https://github.com/python-lsp/python-lsp-server
- https://github.com/pappasam/jedi-language-server

## packaging

Due to historical reasons, poetry is [not yet compliant](https://stackoverflow.com/questions/75408641/whats-difference-between-tool-poetry-and-project-in-pyproject-toml) with [PEP-621](https://packaging.python.org/en/latest/specifications/declaring-project-metadata/), so one has to follow its own syntax to define an entry point:

- https://python-poetry.org/docs/master/pyproject/#scripts

Only after poetry becomes PEP-621 compliant can one follow the official guides:

- https://pypa.github.io/pipx/how-pipx-works/#developing-for-pipx
- https://setuptools.pypa.io/en/latest/userguide/quickstart.html#entry-points-and-automatic-script-creation
- https://setuptools.pypa.io/en/latest/userguide/entry_point.html

## pip & conda skeleton

- always use `pip` in a virtual environment! In such cases, never use `--user`!
- when thinking about `pip --user` try to use `pipx` instead!

`venv` is built into python>=3.3:
- https://docs.python.org/3/library/venv.html

It is also easy to create one with conda.
On the other hand, one can convert `pip` packages to `conda` packages:

- https://www.anaconda.com/blog/using-pip-in-a-conda-environment
- https://docs.conda.io/projects/conda-build/en/latest/user-guide/tutorials/build-pkgs-skeleton.html
- https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html

e.g. [`nbopen.meta.yaml`](./nbopen.meta.yaml) is created with

```
conda skeleton pypi nbopen
```
> There is a bug in `libmamba` such that the build crashes when using custom channel mirrors; a workaround is found in https://github.com/mamba-org/boa/issues/213#issuecomment-1474621395.

`conda skeleton` generates a `meta.yaml` that is close to success; although some manual tweaks are still necessary, including:
- critical fix: https://github.com/bryango/technotes/blob/45b6d900177e33c103e97c52e32c31bd16537776/nbopen.meta.yaml#L24
- nice improvement: https://github.com/bryango/technotes/blob/45b6d900177e33c103e97c52e32c31bd16537776/nbopen.meta.yaml#L17

After that we get a nice little conda package to install: `mamba install --use-local nbopen`.

## shell completions

- `poetry completions zsh` > [`~/.zsh_profiles/completions/_poetry`](https://github.com/bryango/zsh-profiles/blob/-/completions/_poetry)
- zshrc: `compdef mamba=conda` after `conda-setup`
