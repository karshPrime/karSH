
#- Dev Bench -------------------------------------------------------------------
#
# ZSH plugin to create temporary "" directories in /tmp/ to test things out.
# With no argument, tst command will create an empty directory labled /tmp/<NUM>
# where NUM would be  index.
#
# With a numerical argument, the command will check if that indexed
# directory exists, if it does then it would cd there, else it would print
# error.
#
# With language .extension argument, it will use $PROJ_INIT script to create a
# template at /tmp/<NUM> for that language. An example script for this
# purpose can be grabbed from my github-
# https://github.com/karshPrime/SysHacks/blob/main/project_initialise.sh
#
# example usage:
# $ tst
# [ checks if /tmp/1 exists, if it doesn't create it, else check for test2 ]
# [ create /tmp/? & cd /tmp/test? ]
#
# $ bench 1
# [ checks if /tmp/1 exists, if it does, cd there ]
#
# $ bench c
# [ checks if /tmp/1 exists, if it doesn't create it, else check for test2 ]
# [ uses $PROJ_INIT to generate C language project template at /tmp/? ]
#
# $ benchcl
# [ if $pwd in /tmp/? then cd ~ ]
# [ deletes all /tmp/* ]
#
#-------------------------------------------------------------------------------

# Path for project_initialise script
PROJ_INIT="${0:h}/init.sh"
PLAYGROUND="$HOME/.local/Playground"

# Create Playground if it doesn't exit
[[ ! -d $PLAYGROUND ]] && mkdir -p $PLAYGROUND

# Create new project
pinit() { $PROJ_INIT $@; cd "${1%.*}"; main }

# Find the last test directory
bench () {
    # act locally, if first arg is .
	if [[ "$1" == "." ]]
	then
		shift
	else
		cd $PLAYGROUND
	fi

    # if argument is a number, check if that indexed test dir already exists
	# if it does exist then move there
	if [[ "$1" =~ ^[0-9]+$ ]]
	then
		target="./bench$1"
		if [ -d "$target" ]
		then
			cd "$target" || return
			return
		else
			echo "Directory $target does not exist."
			return 1
		fi
	fi

	# find existing biggest test<NUM> dir
	highest=$(
        find . -maxdepth 1 -type d -name "bench*" |
        grep -o '[0-9]*$' |
        sort -n |
        tail -1
    )

	# if no directory found, set the highest to 0
	if [ -z "$highest" ]
	then
		highest=0
	fi

	# increment the highest directory number
	next=$((highest + 1))
	if [ -n "$1" ]
	then
		if ! "$PROJ_INIT" "bench$next.$1"
		then
			echo "Failed to initialize project."
			return 1
		fi
	else
		mkdir "./bench$next"
	fi

	cd "./bench$next/"
}

# Delete all test directories with self remove utility
benchcl () {
	setopt RM_STAR_SILENT
	local cwd=$(pwd)
	if [[ "$1" == "." ]]
	then
		BENCHES="."
	else
		BENCHES=$PLAYGROUND
	fi
	if [[ $cwd == "$BENCHES"* ]]
	then
		cd ~
	fi
	echo "Clearing benches"
	rm -rf "$BENCHES"/bench* > /dev/null 2>&1
}

