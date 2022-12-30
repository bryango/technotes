# My "minimal" working LaTeX setup

- **Rational:** I want a minimal (in size) install, but everything MUST be usable, with semi-automatic package management.
- **Result:** fallback chain:
```bash
tectonic (xelatex) > miktex (pdflatex, ...) > tlmgr (--usermode, infra-only)
                   > nix (biber)            > pacman (texlive-{bin,installer})
```

## `xelatex-tectonic`

A wrapper script to parse `xelatex` flags and pass to `tectonic`, written with python's argparse. See [`~/bin/xelatex-tectonic`](https://github.com/bryango/cheznous/blob/-/bin/xelatex-tectonic). I was hoping to replace `xelatex` completely with `tectonic`. 

Unfortunately, `tectonic` is not perfect yet:
- https://github.com/tectonic-typesetting/tectonic/issues/859: pipe input not available
- https://github.com/tectonic-typesetting/tectonic/issues/893: biber version mismatch, described below
- slow download speed in some regions

So for now I've switched to `xelatex -> miktex-xetex`. 

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

## texlive install

- Use `texlive-installer` from AUR, [with `tk` GUI](https://github.com/bryango/aur/tree/texlive-installer). This also sets up dependencies in pacman. 
- Install minimal components (portable, infrastructure-only), at `$HOME/apps/texlive/$YEAR`
- Link `latest -> $YEAR`
- Next time try to remove `$YEAR` from the installation path (risk: system-breaking annual update).

### launch tlmgr without interference from miktex

See [`~/bin/env-tl`](https://github.com/bryango/cheznous/blob/-/bin/env-tl). Link `tlmgr -> env-tl` in `$PATH` and run `tlmgr` directly.

### let miktex know about the tlmgr tree

Add `texlive/latest/texmf-dist/` to `$TEXMF` in miktex console. See:
- https://miktex.org/faq/local-additions
- https://miktex.org/kb/texmf-roots

## fix file conflicts in miktex

Miktex falsely installs `~/.miktex/texmfs/install/tex/latex/jknappen/ubbold.fd`, a problem described here:
> https://tex.stackexchange.com/questions/164299/missing-character-1-in-font-bbold11

To blacklist the file, simply create an empty `ubbold.fd` and then lock it with `sudo chattr +i`. 

## biber issues

`biber` is tightly coupled with `biblatex`. See https://github.com/plk/biber/issues/427. 

- one can use `nix` to install a matching biber release. 
- ... or, simply use `miktex` which should include matching versions.

`biber` also wants `libcrypt.so.1`, which is not installed by default. This seems to be an Arch issue; the solution is provided [here](https://stackoverflow.com/questions/71171446/biber-wants-to-load-libcrypt-so-1-but-it-is-missing).
