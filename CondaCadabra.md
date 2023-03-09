# Cadabra2 in conda

Cadabra is a powerful computer algebra system maintained by ``our people'', i.e. the `hep-th` clan.
However, it is very difficult to install, since it involves multiple (programming) languages, including python, which is notorious for its environmental issues.
There are far too many pitfalls during the install, so it's useful to document it here.

## refs

- config: https://www.anaconda.com/blog/conda-configuration-engine-power-users

## conda

Initialize conda with [`conda-setup`](https://github.com/bryango/cheznous/blob/c0af2526dfa71a60ba2d81e785e894fd0bec63b6/.shrc#L305). 
Create a new environment to contain cadabra2:
```bash
conda create --name cadabra2
conda activate cadabra2
```
Now configure conda. Note that **`conda config` by default always reads and writes to `~/.condarc`, even if an env is activated!** This is bad, bad ui. Nevertheless, we can write to the env config `$CONDA_PREFIX/.condarc` using
```bash
conda config --env
```
For cadabra2, following the [official guide](https://cadabra.science/download.html),
```bash
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict
```
