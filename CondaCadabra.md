# Cadabra2 in conda

Cadabra is a powerful computer algebra system maintained by _our people_, i.e. the `hep-th` clan.
However, it is very difficult to install, since it involves multiple (programming) languages, including python, which is notorious for its environmental issues.
Here we document the _far too many_ pitfalls during this install, for future convenience.

## conda

Initialize conda; this is set up with [`conda-setup`](https://github.com/bryango/cheznous/blob/c0af2526dfa71a60ba2d81e785e894fd0bec63b6/.shrc#L305) in my system. 
My global config is given by [`~/.condarc`](https://github.com/bryango/cheznous/blob/-/.condarc).
Create a new environment (env) to contain cadabra2, in which the base environment is cloned (so that we have access to e.g. jupyter):
```bash
conda create --name cadabra2 --clone base
conda activate cadabra2
```
Now configure conda. I would suggest going through the official intro of conda config:
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
conda install -v cadabra2 cadabra2-gtk cadabra2-jupyter-kernel
```
