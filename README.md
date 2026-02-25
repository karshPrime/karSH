# Karsh's Shell

This repository contains all the plugins used in a Z Shell environment, featuring three key
plugins from other developers and two custom creations.


## Plugins

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting):
  Enhances the command prompt with syntax highlighting, making commands easier to read and errors
  more noticeable.

- [zsh-defer](https://github.com/romkatv/zsh-defer):
  Optimises shell startup time by deferring the loading of functions until they are invoked.


## Custom Plugins

- `newproject`:
  Plugin designed to assist in creating new projects and testing benches based on specified
  templates.

- `devedit`:
  Introduces a set of useful commands for development, enhancing workflow and editing capabilities.


### Added Commands

#### DevEdit Commands

- `vi`:
  Allows selection of multiple files for editing based on specified extensions or the current
  directory, utilising `fzf` for file selection and `bat` for previewing file contents. It opens all
  selected files in the editor. 

- `main`:
  Checks for common main files (like `main.*`, `index.*`, or `init.*`) and opens the first found in
  the editor; reports an error if none exist.

- `readme`:
  Locates the project's README file and opens it; displays an error message if not found.

- `makefile`:
  Opens the Makefile in the project root directory; creates it if it doesn't exist.

- `gconfig`:
  Opens the `.git/config` file located in the project root; checks existence and reports errors.

- `gignore`:
  Opens the `.gitignore` file found in the project root; displays an error if the file is missing.

- `parent`:
  Changes the current directory to the project's root directory.

- `isGit`:
  Checks if the current directory is within a Git repository, returning an error message if it’s
  not.

- `ve`:
  Opens a specified file in the editor if it exists; otherwise, it reports an error stating the file
  was not found.


#### NewProject Commands

- `pinit`:
  Executes the project initialisation script with provided arguments and navigates into the newly
  created project directory, then invokes the main function.

- `bench`:
  Navigates to or creates the next available test directory within the playground:
  - If the first argument is `.` (current directory), it operates locally; otherwise, it navigates
    to the `$PLAYGROUND`.
  - If the argument is a number, it checks for the existence of the corresponding test directory
    (e.g., `bench1`, `bench2`, etc.) and moves into it if found. If the directory does not exist, an
    error message is displayed.
  - If no existing directories are found, it determines the highest numbered directory, increments
    it, and creates a new test directory. If a second argument is provided, it initialises a new
    project using that argument (`pinit` as a bench).

- `benchcl`:
  Deletes all test directories prefixed with "bench" from the `$PLAYGROUND`, cleaning up any
  previous test setups.

\* `$PLAYGROUND` by default is set as `$HOME/.local/Playground`.

