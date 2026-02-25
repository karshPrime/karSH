
#- DevEdit -----------------------------------------------------------------------------------------
#
# ZSH plugin to quickly edit commonly used, language-agnostic files like .gitignore, main.*, README,
# and more with a single command.
#
# It simplifies development by abstracting away the details of file locations or project structure,
# allowing you to focus on coding instead of navigating directories.
#
# vi, short for vim interactive, extends the script further by using fzf and bat to find all files
# of stated file extension.
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
#---------------------------------------------------------------------------------------------------

# helper functions ---------------------------------------------------------------------------------

# check if pwd is in a git repo
alias isGit='
	if ! git rev-parse --is-inside-work-tree &> /dev/null; then
		echo -e "\e[31mError: \e[0mThis action requires the project to be within a git repo."
		return 1
	fi
'

# open file if it Exists
ve() {
	if [ -f "$1" ]; then
		$EDITOR "$1"
	else
		echo -e "\e[31mError: \e[0mFile not found: $1"
	fi
}


# calls --------------------------------------------------------------------------------------------

# Edit README
alias readme='\
	isGit;
	PROJECT_NAME=$(git rev-parse --show-toplevel) &&
	README_FILE=$(ls "$PROJECT_NAME"/README* 2>/dev/null) &&

	if [ -z "$README_FILE" ]; then
		echo -e "\e[31mError: \e[0mNo README file found."
	else
		ve "$README_FILE"
	fi
'

# Edit Makefile
alias makefile='
	isGit;
	PROJECT_NAME=$(git rev-parse --show-toplevel) &&

	ve "$PROJECT_NAME/Makefile"
'

# Edit .git/config
alias gconfig='
	isGit;
	PROJECT_NAME=$(git rev-parse --show-toplevel) &&

	ve "$PROJECT_NAME/.git/config"
'

# Edit .git/config
alias gignore='
	isGit;
	PROJECT_NAME=$(git rev-parse --show-toplevel) &&

	ve "$PROJECT_NAME/.gitignore"
'

# Edit main.x
alias main='
	isGit;
	PROJECT_NAME=$(git rev-parse --show-toplevel) &&

	MAIN_FILE=$(git ls-files "$PROJECT_NAME" | grep -i -E "main|index|init") &&

	if [ -z "$MAIN_FILE" ]; then
		echo -e "\e[31mError: \e[0mNo main file found."
	else
		ve "$MAIN_FILE"
	fi
'

# cd to project root
alias parent='
	isGit;
	PROJECT_NAME=$(git rev-parse --show-toplevel) &&

	cd "$PROJECT_NAME"
'

# Vim Interactive
vi() {
	local CONDITIONS=()
    local DIRS=()
    local FILES=""
	local term_width=$(tput cols 2>/dev/null || echo 0)

	# construct find conditions based on arguments
	for ARG in "$@"; do
		if [ "$ARG" = "." ]; then
            DIRS+=(".")
        elif [[ $ARG == .* ]]; then
            DIRS+=( "$ARG" )
		else
			CONDITIONS+=("-iname" "*.$ARG" "-o")
		fi
	done

    # search in current dir if DIR is empty
    if [[ ${#DIRS[@]} -eq 0 ]]; then
        DIRS=(".")
    fi

	# remove trailing '-o' if present
	if [ ${#CONDITIONS[@]} -gt 0 ]; then
		if [ "${CONDITIONS[-1]}" = "-o" ]; then
			CONDITIONS=("${CONDITIONS[@]:0:${#CONDITIONS[@]}-1}")
		fi

        for dir in "${DIRS[@]}"; do
		    # find files based on constructed conditions, excluding .git directory
            FILES+=$(find "$dir" \( -type f -o -type l \) \( "${CONDITIONS[@]}" \) -not -path './build/*' -not -path '**/.*')
        done
	else
        for dir in "${DIRS[@]}"; do
            FILES+=$(find "$dir" \( -type f -o -type l \) -not -path './build/*' -not -path '**/.*')
        done
	fi

	# use fzf to select files, displaying with bat
	local FILES_OPEN=$(
		if [ "$term_width" -lt 140 ]; then
			echo "$FILES" |
			sort |
			fzf -m \
				--preview-window=down:70%:wrap \
				--preview='echo -e "$(basename {})" && bat --color=always --number {}'
		else
			echo "$FILES" |
			sort |
			fzf -m \
				--preview-window=right:150:wrap \
				--preview='echo -e "$(basename {})" && bat --color=always --number {}'
		fi
	)
	# Count the number of selected files
	local FILE_COUNT=$(echo "$FILES_OPEN" | wc -l | tr -d ' ')

	# open the selected files in the editor
	if [ -z "$FILES_OPEN" ]; then
		echo "No files selected."

    else
        # Use vertical splits with a dynamic count
        # Compute how many splits to open: min(file count, columns/100), at least 1
        local cols_per_100=$(( $term_width / 100 ))
        [ "$cols_per_100" -lt 1 ] && cols_per_100=1

        # min(FILE_COUNT, cols_per_100)
        if [ "$FILE_COUNT" -le "$cols_per_100" ]; then
            split_count="$FILE_COUNT"
        else
            split_count="$cols_per_100"
        fi

        $EDITOR -O"$split_count" $(echo "$FILES_OPEN")

    fi
}

