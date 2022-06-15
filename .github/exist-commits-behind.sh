#!/bin/bash
###
# Validate if it exists commits in master/main not merged into <division>/develop branch.
# 1: No; 0: Yes
###
primary_branch=${1}
secondary_branch=${2}

git cherry -v $secondary_branch $primary_branch | while read line; do
  if [[ $line == \+* ]]; then
    exit 1
  fi
done
if [[ $? -eq 1 ]]; then
  echo 0
else
  #string not found
  echo 1
fi