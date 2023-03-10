# Cadabra2 in mamba

Cadabra is a powerful computer algebra system maintained by _our people_, i.e. the `hep-th` clan.
However, it is very difficult to install, since it involves multiple (programming) languages, including python, which is notorious for its environmental issues.
Here we document the _far too many_ pitfalls during this install, for future convenience.

## mamba & jupyter

Mamba is a drop-in replacement for conda written in C++. Documentations:
> https://mamba.readthedocs.io/en/latest/index.html

The installer is call `Mambaforge` and it's quite similar to anaconda. I've chosen to set it up in `~/apps/mambaforge`. We also need to source some shell snippets to initialize the environment. This is done with [`conda-setup`](https://github.com/bryango/cheznous/blob/c0af2526dfa71a60ba2d81e785e894fd0bec63b6/.shrc#L305) in my system.

My global config is provided by [`~/.condarc`](https://github.com/bryango/cheznous/blob/-/.condarc). Install jupyter globally so that it can be used by others:
```bash
mamba install -n base jupyterlab
```
Although `conda` is available in a `mamba` system, **always use the `mamba` command to install things.** It is lightning fast compared to `conda`. Well actually, mamba is not _that_ fast; the thing is that conda is just horrendously slow. To install something on top of a system `anaconda` release, it would take like _a few hours_ to resolve dependencies. Updating the anaconda release beforehand will greatly smooth out the process, but this defeats the whole purpose of having a system level anaconda release: to delegate the package management to the system `pacman`. I've hence given up the system level anaconda install and settled for a user level `mambaforge` mini-environment, in which jupyter has to be manully installed. As a fallback one can also set `libmamba` to be the solver backend of conda:
```bash
mamba install -n base conda-libmamba-solver
conda config --set solver libmamba
```
See https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community. 

We will create a new environment (env) to contain cadabra2:
```bash
mamba create --name cadabra2
mamba activate cadabra2
```
To access jupyter in this pristine environments, use environment **_stacking_:**
```bash
mamba activate base
mamba activate --stack cadabra2
```
However, during setup we would like the env to be minimal, so no stacking for now:
```bash
mamba deactivate
mamba activate cadabra2
```

## conda config

We then switch back to the `conda config` command for configuration. I would suggest going through the official intro:
> https://www.anaconda.com/blog/conda-configuration-engine-power-users

before continuing. In particular, note that **`conda config` by default always reads and writes to `~/.condarc`, even if an env is activated!** This is bad, bad ui. Nevertheless, we can write to the env config `$CONDA_PREFIX/.condarc` using
```bash
conda config --env
```
Note that `conda config --env` only writes to `$CONDA_PREFIX/.condarc` even if there is already another config file, e.g. `$CONDA_PREFIX/condarc` (without the dot). Is this a feature or a bug? I have no idea...

For cadabra2, following the [official guide](https://cadabra.science/download.html),
```bash
# conda config --env --set channel_priority strict  ### skipped, to relax the deps
conda config --env --add channels conda-forge
```
According to the doc, adding `#!top` to the channel ensures that it's on the top of the list:
```
$ cat "$CONDA_PREFIX/.condarc"
channels:
  - conda-forge #!top
  - defaults
```
Let us see the result:
```
$ conda config --get channels
--add channels 'conda-forge'   # lowest priority
--add channels 'defaults'   # highest priority
```
Huh? It's not working. What happened? **Jokes on you, you forgot the `--env`!** One would naturally assume that `config --get` would print the resolved config, but no, it knows only about `~/.condarc`. Maybe I am assuming too much. The correct keyword, as it turns out, is `--show`:
```
$ conda config --show channels 
channels:
  - conda-forge
  - defaults
```
The config sources are shown with `--show-sources`. This is bad, bad ui. I would suggest using `read` instead of the current `get`, and `get` in place of the current `show`.

## cadabra

We can finally install cadabra:
```bash
mamba install cadabra2 cadabra2-gtk cadabra2-jupyter-kernel
```
Clean up the cache afterwards:
```bash
mamba clean --all
```
