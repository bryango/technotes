# Cadabra2 in mamba

Cadabra is a powerful computer algebra system maintained by _our people_, i.e. the `hep-th` clan.
However, it is very difficult to install, since it involves multiple (programming) languages, including python, which is notorious for its environmental pollution.
Here we document the _far too many_ pitfalls during this install, for future convenience.

**Note:** The following passage contains too many complaints on the conda ecosystem. This is not targeted at the wonderful community, nor the volunteers that are doing invaluable work maintaining it. This document is created for my personal use, and I simply need to let out my frustration.
> Although, after reviewing parts of the conda source (written in python), it seems to me that the code is of high quality. Maybe the problem is design: perhaps python is simply not suitable for this kind of workload. 

## mamba & jupyter

Mamba is a drop-in replacement for conda written in C++. Documentations:
> https://mamba.readthedocs.io/en/latest/index.html

The installer is called `miniforge` and it's quite similar to anaconda, except that it is tied to the community channel `conda-forge`. Basically,
- the official `anaconda` distribution comes with `conda` and the `defaults` channel
- while the community `miniforge` comes with `mamba` & `conda` and the `conda-forge` channel

I've chosen to set up the miniforge in `~/apps/mambaforge`. We also need to source some shell snippets to initialize the environment. This is done with [`conda-setup`](https://github.com/bryango/cheznous/blob/c0af2526dfa71a60ba2d81e785e894fd0bec63b6/.shrc#L305) in my system.

My global config is provided by [`~/.condarc`](https://github.com/bryango/cheznous/blob/-/.condarc). Install jupyter globally so that it can be used by others:
```bash
mamba install -n base jupyterlab
```
Although `conda` is available in a `mamba` system, **always use the `mamba` command to install things.** It is lightning fast compared to `conda`. Well actually, mamba is not _that_ fast; the thing is that conda is just horrendously slow. To install something on top of a system `anaconda` release, it would take like _a few hours_ to resolve dependencies. Updating the anaconda release beforehand will greatly smooth out the process, but this defeats the whole purpose of having a system level anaconda release: to delegate the package management to the system `pacman`. I've hence given up the system level anaconda install and settled for a user level `mambaforge` mini-environment, in which jupyter has to be manully installed. As a precaution I also set `libmamba` to be the solver backend of conda:
```bash
mamba install -n base conda-libmamba-solver
conda config --set solver libmamba
```
See https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community. This may or may not improve the solver performance of `conda-build`.

**Update:** as of Jan. 2025, `libmamba` is now the default resolver for conda so we may no longer need to do this manually.

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
mamba install cadabra2-gtk cadabra2-jupyter-kernel
```
The main program `cadabra2` will be installed as a dependency.
We can clean up the cache afterwards:
```bash
mamba clean --all
conda clean --all
```

## conda mambabuild

To use the latest version, build from source in the conda environment. I haven't succeeded in this endeavor, but I've learned things along the way; e.g. `conda-build` is equally awful for the same reasons as `conda`. A replacement called `boa` is provided by the mamba team, but it is still experimental; after installing `boa`, one can run:
```bash
conda mambabuild
```
As a replacement for `conda build`. The build cache is cleared with
```bash
conda build purge
```

Recipes:

- https://github.com/kpeeters/cadabra2/tree/master/conda
- https://github.com/conda-forge/cadabra2-feedstock/tree/main/recipe

Flags:

- https://github.com/kpeeters/cadabra2/blob/master/CMakeLists.txt
- https://github.com/conda-forge/cadabra2-feedstock/issues/36

## revisions

After nuking the environment one may want to restore to a previous revision. This is achieved by:
```bash
conda list --revisions
conda install --revision # <number>
```
To restore the pristine env, without removing `--all` and recreating one, simply specify `--revision 0`. Note that switching to `--revision n` with `n > 0` is usually slow, as always with conda. Revisions are not yet implemented in mamba (see https://github.com/mamba-org/mamba/issues/803).
