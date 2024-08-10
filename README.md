# karsh's SHell

This repository lists the plugins I've written for the [z shell](https://www.zsh.org).
Most of them are dependent opon existing tools like
[`fzf`](https://github.com/junegunn/fzf), [`bat`](https://github.com/sharkdp/bat) (for
`fzf` preview, could be changed with `cat` with no issue though), in addition to core
utils, like `find` and `grep`.


## Plugin Description

### devedit.zsh
Plugin to simplify editing commonly used development files like `.gitignore`, `README`,
and `main` files (`main.*`, `index.*`, `init.*`) by allowing quick access with a single
command. It abstracts away the need to navigate directories or remember file locations,
enabling developers to focus more on coding. Additionally, the vi command integrates fzf
and bat to search for files by extension and open them in the preferred editor.

### devtest.zsh
Plugin facilitates the creation and management of temporary test directories in `/tmp/`.

The `tst` command automatically creates a numbered test directory, such as `/tmp/test1`, and
navigates to it. If a file extension is specified, it uses a 
[project_initialization](https://github.com/karshPrime/SysHacks/blob/main/project_initialise.sh)
script to create a language-specific project template in the new directory.
The plugin also includes a `tstrm` command to clean up by deleting all test directories.

