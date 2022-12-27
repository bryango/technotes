# Install Mathematica on Manjaro / Arch Linux

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


