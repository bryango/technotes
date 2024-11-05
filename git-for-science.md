# Version-control your scientific projects

wip

Computer people invented the modern version control systems for code,
but it is not just good for code!
Good for anything that can be represented by plain texts (binaries not so good).

- Reliable collaboration, nothing is lost
- Stick to linear history at the beginning (`rebase` instead of `merge`)
- Be careful of random git commands (`reset`, `clean`, ...)
- Install [**git-branchless**](https://github.com/arxanas/git-branchless) if you are a command line person, and take advantage of `git undo`
- Any graphical git client is good enough for beginners; if using GitHub, just [use the official GitHub client](https://member.ipmu.jp/yuji.tachikawa/misc/overleaf-git.html)
- Just `--abort` when things happen
- Next level: non-linear histories and stuff: do _not_ try to be a git expert; instead, learn to use [**git-branchless**](https://github.com/arxanas/git-branchless) and [jj](https://steveklabnik.github.io/jujutsu-tutorial/) (always colocate with git)

Sample git config:
```gitconfig
[merge]
	ff = only
[receive]
	denyNonFastForwards = true
[remote "origin"]
[branch "master"]
[remote "private"]
[branch "p13n"]
```

Hooks:
```bash
#!/bin/bash
# pre-commit: protect the master
# https://stackoverflow.com/questions/40462111

branch="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$branch" = "master" ]]; then
  echo "cannot commit directly to the master branch"
  exit 1
fi

#!/bin/bash
# pre-push: fetch before push
# https://stackoverflow.com/questions/40462111

git fetch --all
```
