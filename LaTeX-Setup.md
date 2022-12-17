# My "minimal" but functional LaTeX setup

- **Rational:** I want a minimal (in size) install, but everything MUST be functional, with semi-automatic package management.
- **Result:** fallback chain:
```bash
tectonic (xelatex) > miktex (pdflatex, ...)
                   > nix (biber) > pacman (biber)
                                 > pacman (texlive-{bin,installer}) > tlmgr (--usermode, infra-only)
```

## `$PATH` sequence

```bash
$ echo "$PATH" | sed "s|$HOME|\$HOME|g" | tr : '\n'

$HOME/bin
$HOME/.nix-profile/bin
$HOME/apps/miktex/bin
/usr/bin
$HOME/apps/texlive/latest/bin/x86_64-linux

# ... unrelated entries removed
```


## Launch tlmgr without interference from miktex

See [`env-tl`](./env-tl). Link `tlmgr -> env-tl` in `$PATH` and run `tlmgr` directly.


## Let miktex know about the tlmgr tree

Add `texlive/latest/texmf-dist/` to `$TEXMF` in miktex console. See:
- https://miktex.org/faq/local-additions
- https://miktex.org/kb/texmf-roots
