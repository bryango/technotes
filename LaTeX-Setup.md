# My "minimal" working LaTeX setup

- **Rational:** I want a minimal (in size) install, but everything MUST be usable, with semi-automatic package management.
- **Result:** fallback chain:
```bash
tectonic (xelatex) > miktex (pdflatex, ...) > tlmgr (--usermode, infra-only)
                   > nix (biber)            > pacman (biber)
                                            > pacman (texlive-{bin,installer})
```

## `xelatex -> tectonic`

I've written a wrapper script with python's argparse. See [](/cheznous/bin/xelatex). 

## `$PATH` sequence

```bash
$ echo "$PATH" | sed "s|$HOME|\$HOME|g" | tr : '\n'

$HOME/bin
$HOME/.nix-profile/bin
$HOME/apps/miktex/bin
$HOME/apps/texlive/latest/bin/x86_64-linux
/usr/bin

# ... unrelated entries removed
```

## Launch tlmgr without interference from miktex

See [`env-tl`](/cheznous/bin/env-tl). Link `tlmgr -> env-tl` in `$PATH` and run `tlmgr` directly.

## Let miktex know about the tlmgr tree

Add `texlive/latest/texmf-dist/` to `$TEXMF` in miktex console. See:
- https://miktex.org/faq/local-additions
- https://miktex.org/kb/texmf-roots

## Fix file conflicts in miktex

Miktex falsely installs `~/.miktex/texmfs/install/tex/latex/jknappen/ubbold.fd`, a problem described here:
> https://tex.stackexchange.com/questions/164299/missing-character-1-in-font-bbold11

To blacklist the file, simply create an empty `ubbold.fd` and then lock it with `sudo chattr +i`. 
