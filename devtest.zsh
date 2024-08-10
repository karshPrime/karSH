
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

# Find the last test directory
tst() {
	# if argument is a number, check if that indexed test dir already exists
	# if it does exist then move there
	if [[ "$1" =~ ^[0-9]+$ ]]; then
		target="/tmp/test${1}"

		if [ -d "$target" ]; then
			cd "$target" || return
			return
		else
			echo "Directory $target does not exist."
			return 1
		fi
    fi

	# find existing biggest test<NUM> dir
	highest=$(
		find /tmp/ -maxdepth 1 -type d -name "test*" |
		grep -o '[0-9]*$' |
		sort -n |
		tail -1
	)

	# if no directory found, set the highest to 0
	if [ -z "$highest" ]; then
		highest=0
	fi

	# increment the highest directory number
	next=$((highest + 1))

	# trigger project init script
	if [ -n "$1" ]; then
		$PROJ_INIT "test${next}.$1"
		mv "./test${next}" /tmp/
	else
		mkdir "/tmp/test${next}"
	fi

	cd "/tmp/test${next}/"
}

# Delete all test directies with self remove utility
tstrm() {
    local cwd=$(pwd)

    if [[ $cwd == /tmp/test* ]]; then
        cd ~
    fi

	rm -rf /tmp/test*
}

