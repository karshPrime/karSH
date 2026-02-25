#!/usr/bin/env bash

#-Project Structure-------------------------------------------------------------

uv init .
#
# #-Git Ignore--------------------------------------------------------------------

echo "
__pycache__/
*.py[oc]
build/
dist/
wheels/
*.egg-info
.venv
" >> .gitignore

