# Cadabra2 in conda

Cadabra is a powerful computer algebra system maintained by _our people_, i.e. the `hep-th` clan.
However, it is very difficult to install, since it involves multiple (programming) languages, including python, which is notorious for its environmental issues.
Here we document the _far too many_ pitfalls during this install, for future convenience.

## refs

- config: https://www.anaconda.com/blog/conda-configuration-engine-power-users

## conda

Initialize conda with [`conda-setup`](https://github.com/bryango/cheznous/blob/c0af2526dfa71a60ba2d81e785e894fd0bec63b6/.shrc#L305). 
Create a new environment (env) to contain cadabra2:
```bash
conda create --name cadabra2
conda activate cadabra2
```
Now configure conda. Note that **`conda config` by default always reads and writes to `~/.condarc`, even if an env is activated!** This is bad, bad ui. Nevertheless, we can write to the env config `$CONDA_PREFIX/.condarc` using
```bash
conda config --env
```
Note that `conda config --env` only writes to `$CONDA_PREFIX/.condarc` even if there is already another config file, e.g. `$CONDA_PREFIX/condarc` (without the dot). Is this a feature or a bug? I have no idea...
For cadabra2, following the [official guide](https://cadabra.science/download.html),
```bash
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict
```
Let us see the result:
```bash
conda config --get channel_priority
```
Huh? Nothing shows up. What happened? **Jokes on you, you forget the `--env`!** This is finally correct:
```bash
conda config --env --get channel_priority
# --set channel_priority strict
```
One would naturally assume that `config --get` would print the resolved config, but no, it knows only about `~/.condarc`. The correct keyword is `--show`:
```
$ conda config --show channels channel_priority 
channels:
  - conda-forge
  - defaults
channel_priority: strict
```
