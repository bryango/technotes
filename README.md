# technotes

My notes about tech. Finished notes will be indexed here. Work in progress will be scattered in the repo.

## [Installing Manjaro, the Arch way, on Btrfs](./ManjaroInstall.md)

Why?
- Arch is perfect, but always rolling.
- Manjaro is stable, but too bloated.
- btrfs is a no-brainer. Sweet copy on write!

> **Note:** for btrfs, CoW has long been the glib default!
> See: https://gitlab.gnome.org/GNOME/glib/-/issues/2151. 
> So CoW works natively in nautilus! No need to `cp --reflink=always`!
