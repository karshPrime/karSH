
#- DevTest ---------------------------------------------------------------------
#
# ZSH plugin to create temporary "test" directories in /tmp/ to test things out.
# With no argument, tst command will create an empty directory labled /tmp/<NUM>
# where NUM would be test index.
#
# With a numerical argument, the command will check if that indexed test
# directory exists, if it does then it would cd there, else it would print
# error.
#
# With language .extension argument, it will use $PROJ_INIT script to create a
# template at /tmp/test<NUM> for that language. An example script for this
# purpose can be grabbed from my github-
# https://github.com/karshPrime/SysHacks/blob/main/project_initialise.sh
#
# example usage:
# $ tst
# [ checks if /tmp/test1 exists, if it doesn't create it, else check for test2 ]
# [ create /tmp/test? & cd /tmp/test? ]
#
# $ tst 1
# [ checks if /tmp/test1 exists, if it does, cd there ]
#
# $ tst c
# [ checks if /tmp/test1 exists, if it doesn't create it, else check for test2 ]
# [ uses $PROJ_INIT to generate C language project template at /tmp/test? ]
# 
# $ tstrm
# [ if $pwd in /tmp/test? then cd ~ ]
# [ deletes all /tmp/test* ]
#
#-------------------------------------------------------------------------------

# Path for project_initialise script
PROJ_INIT="$HACK_SCRIPTS/project_initialise.sh"
TEST_DIR="$HOME/Projects/.test"

# Find the last test directory
bench () {
    # act locally, if first arg is .
	if [[ "$1" == "." ]]
	then
		BENCHES="." 
		shift
	else
		BENCHES=$PLAYGROUND 
	fi

    # if argument is a number, check if that indexed test dir already exists
	# if it does exist then move there
	if [[ "$1" =~ ^[0-9]+$ ]]
	then
		target="$BENCHES/bench$1" 
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
        find "$BENCHES" -maxdepth 1 -type d -name "bench*" |
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
		mv "./bench$next" "$BENCHES/." 2> /dev/null
	else
		mkdir "$BENCHES/bench$next"
	fi
	cd "$BENCHES/bench$next/"
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

