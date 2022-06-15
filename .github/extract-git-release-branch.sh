#!/bin/bash
###
# Extract release branch
# input branch pattern/name
###
branch_to_find=${1}

release_branch=$(git ls-remote --exit-code --heads origin ${branch_to_find})

regex="[a-z]*\/release\/[0-9]*(\.[0-9]*)*"
[[ $release_branch =~ $regex ]] && echo $BASH_REMATCH