#!/usr/bin/env bash

# This script automates project setup tasks, including directory creation, Git
# initialisation, README file generation and commit, language-specific file
# setup, and .gitignore configuration.

# Username
export GIT_USER="karsh"

LICENSE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/DEFAULT_LICENSE"
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates"

# Project Description
LANGUAGE="${1##*.}"
export PROJECT_TITLE="${1%.*}"

echo "Initialising Project at $(pwd)/$PROJECT_TITLE"

# Initialise Project
mkdir "$PROJECT_TITLE"
cd "$PROJECT_TITLE"
cp $LICENSE .
echo -e "# $PROJECT_TITLE\n\n" > README.md

# Initialise Git
git init --quiet
git remote add origin "git@github.com:$GIT_USER/$PROJECT_TITLE.git"
echo -e "\n# .gitignore\n\n**/.DS_Store\n**/todo" > .gitignore

if [ -f "${SCRIPTS}/${LANGUAGE}.sh" ]; then
    "${SCRIPTS}/${LANGUAGE}.sh"
else
    echo "Template for $LANGUAGE not found."
fi

# Commit Template
git add -A
git commit -m "init: project"

