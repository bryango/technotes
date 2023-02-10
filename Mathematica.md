# Mathematica cookbook

## Tips & tricks

Here we collect misc tips & tricks that are less than universal; more universal tricks are bundled in the repo [**bryango/Physica**](https://github.com/bryango/Physica), in particular, [`MathUtils.wl`](https://github.com/bryango/Physica/blob/-/MathUtils.wl) and [`GRUtils.wl`](https://github.com/bryango/Physica/blob/-/GRUtils.wl) therein.

- _Symbolize_ an expression, just like the <code>Notation`</code> Package.
```wolfram
{SubPlus[r], SubMinus[r]} := {rp, rm};
MakeBoxes[rp, StandardForm] ^= MakeBoxes[SubPlus[r]]
MakeBoxes[rm, StandardForm] ^= MakeBoxes[SubMinus[r]]
```
In this case $r_\pm$ is treated internally as `{rp, rm}`, but is displayed as $r_\pm$.

- Use `Unevaluated` to pass argument as held:
```wolfram
(ClearAll[#]; Remove[#]) & @ Unevaluated[logZ]
```

## Installation on Manjaro / Arch Linux

- See [`bryango/aur: mathematica*`](https://github.com/bryango/aur/tree/mathematica) which is based on [`aur: mathematica`](https://aur.archlinux.org/packages/mathematica).
- The suffix, e.g. `-13.2` in `mathematica-13.2`, indicates the version.
- Note that mathematica-`13.1` has a [serious x11 scrolling bug](https://mathematica.stackexchange.com/questions/271889/touchpad-rough-scrolling-in-version-13-1-linux) that renders it unusable for me. I have to downgrade to `13.0` and later upgrade to `13.2`. Fortunately it is fixed in `13.2`. I use git branches to keep track of the versions:

```gitconfig
# cat .git/config
[core]
	repositoryformatversion = 1
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = git@github.com:bryango/aur.git
	fetch = +refs/heads/mathematica*:refs/remotes/origin/mathematica*
	promisor = true
	partialclonefilter = blob:none
[remote "upstream"]
	url = git@github.com:archlinux/aur.git
	fetch = +refs/heads/mathematica:refs/remotes/upstream/mathematica
[branch "mathematica"]
	remote = origin
	merge = refs/heads/mathematica
[branch "mathematica-13.0"]
	remote = origin
	merge = refs/heads/mathematica-13.0
[branch "mathematica-13.1"]
	remote = origin
	merge = refs/heads/mathematica-13.1
[branch "mathematica-13.2"]
	remote = origin
	merge = refs/heads/mathematica-13.2
```


