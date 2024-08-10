
#- DevEdit ---------------------------------------------------------------------
#
# ZSH plugin to quickly edit commonly used, language-agnostic files like
# .gitignore, main.*, README, and more with a single command.
#
# It simplifies development by abstracting away the details of file locations
# or project structure, allowing you to focus on coding instead of navigating
# directories.
#
# vi, short for vim interactive, extends the script further by using fzf and bat
# to find all files of stated file extension.
#
# example usage:
# $ main
# [ checks for main.* , index.* & init.* ]
# [ if result found open it in $EDITOR. Otherwise print not found ]
#
# $ readme
# [ check $PROJECT_ROOT/README* if found open it in $EDITOR, else print result ]
#
# $ parent
# [ cd to project root ]
#
# $ makefile
# [ open $PROJECT_ROOT/Makefile in $EDITOR, if blank then open blank file there ]
## same for gignore (for .gitignore) and .git/config
#
# $ vi
# [ list all files in the project in fzf, open all selected files in $EDITOR ]
#
# $ vi .
# [ list all files in the current pwd with fzf, open selected ones in $EDITOR]
#
# $ vi c .
# [ list all .c files in current pwd with fzf, open selected ones in $EDITOR ]
#
#-------------------------------------------------------------------------------

# helper functions -------------------------------------------------------------

exit_if_not_git_repo() {
	if ! git rev-parse --is-inside-work-tree &> /dev/null; then
		echo -e "\e[31mError: \e[0mThis action requires the project to be within a git repo."
		return 1
	fi
}

open_file_if_exists() {
	if [ -f "$1" ]; then
		$EDITOR "$1"
	else
		echo -e "\e[31mError: \e[0mFile not found: $1"
	fi
}


# calls ------------------------------------------------------------------------

# Edit README
readme() {
	exit_if_not_git_repo || return
	PROJECT_NAME=$(git rev-parse --show-toplevel)
	README_FILE=$(ls "$PROJECT_NAME"/README* 2>/dev/null)

	if [ -z "$README_FILE" ]; then
		echo -e "\e[31mError: \e[0mNo README file found."
	else
		open_file_if_exists "$README_FILE"
	fi
}

# Edit Makefile
makefile() {
	exit_if_not_git_repo || return
	PROJECT_NAME=$(git rev-parse --show-toplevel)

	open_file_if_exists "$PROJECT_NAME/Makefile"
}

# Edit .git/config
gignore() {
	exit_if_not_git_repo || return
	PROJECT_NAME=$(git rev-parse --show-toplevel)

	open_file_if_exists "$PROJECT_NAME/.git/config"
}

# Edit main.x
main() {
	exit_if_not_git_repo || return
	PROJECT_NAME=$(git rev-parse --show-toplevel)

	MAIN_FILE=$(git ls-files "$PROJECT_NAME" | grep -i -E "main|index|init")

	if [ -z "$MAIN_FILE" ]; then
		echo -e "\e[31mError: \e[0mNo main file found."
	else
		open_file_if_exists "$MAIN_FILE"
	fi
}

# cd to project root
parent() {
	exit_if_not_git_repo || return
	PROJECT_NAME=$(git rev-parse --show-toplevel)

	cd "$PROJECT_NAME"
}

# Vim Interactive
vi() {
	exit_if_not_git_repo || return
	pushd "$(git rev-parse --show-toplevel)" > /dev/null

	local CONDITIONS=()
	local term_width=$(tput cols)

	# construct find conditions based on arguments
	for ARG in "$@"; do
		if [ "$ARG" = "." ]; then
			popd > /dev/null
			pushd . > /dev/null
		else
			CONDITIONS+=("-iname" "*.$ARG" "-o")
		fi
	done

	# remove trailing '-o' if present
	if [ ${#CONDITIONS[@]} -gt 0 ]; then
		if [ "${CONDITIONS[-1]}" = "-o" ]; then
			CONDITIONS=("${CONDITIONS[@]:0:${#CONDITIONS[@]}-1}")
		fi
		# find files based on constructed conditions, excluding .git directory
		FILES=$(find "." -type f \( "${CONDITIONS[@]}" \) -not -path '*/.git/*')
	else
		FILES=$(find "." -type f -not -path '*/.git/*')
	fi

	# use fzf to select files, displaying with bat
	local FILES_OPEN=$(
		if [ "$term_width" -lt 100 ]; then
			echo "$FILES" |
			sort |
			fzf -m --preview-window=down:70%:wrap \
				--preview="bat --color=always --number {}"
		else
			echo "$FILES" |
			sort |
			fzf -m --preview-window=right:50%:wrap \
				--preview="bat --color=always --number {}"
		fi
	)
	# Count the number of selected files
	local FILE_COUNT=$(echo "$FILES_OPEN" | wc -l)

	# open the selected files in the editor
	if [ -z "$FILES_OPEN" ]; then
		echo "No files selected."
	elif [ "$FILE_COUNT" -gt 1 ]; then
		$EDITOR -O2 $(echo "$FILES_OPEN")
	else
		$EDITOR $(echo "$FILES_OPEN")
	fi
	popd > /dev/null
}
