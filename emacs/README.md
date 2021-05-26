
This is my emacs configuration file.
Changes are made directly with emacs on the file `config.org`.
There is an auto-tangle function which, upon saving, automatically retangles this emacs configuration
in `init.el`. This saves some milliseconds since Emacs doesn't have to recompile this file every time
it is open in a new session.

The folder functions has some files improving the functioning of `org-agenda`.
I use `straight` as my package manager, in the layout of `use-package`.
There are some changes made on the source code of some packages, which are listed below.

Configuration on the file `cemitery.org` is no longer used, but was still functional in the last time 
it was active.
Sometimes I change my mind regarding some of the packages there, so it is easier to just have a 
file that preserves those in a structured manner.

# Changes on the source

Packages:
- evil-collection - changed the behavior of `gj` and `gk` on `org` buffers.
- yankpad - fixed some problems with snippets having special characters, such as "lr(".
- doom-themes - fixed repo on commit  "3a430a1299a9ddad272d92511b4745cc2716611f" since 
  I didn't like the changes introduced after on the gruvbox theme (2021/11/02).
- orgmode - removed `hyperref` from `org-latex-default-packages-alist` in file org.el.
  The modification is in my custom emacs file.

# Notes on using straight

To change repo versions, you have to manually edit the `default.el` lockfile with the commit you want.
To use a fork of a repository, you have to change the recipe in the lockfile, run `straight-normalize-package`
and then freeze the lockfile with `straight-freeze-versions`. In my experience, before freezing versions
it is also necessary to delete the cache and the specific packages that were changed in the folder build and repos.
