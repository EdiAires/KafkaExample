#!/bin/bash
###
# Validate if input branch exists in origin.
# 1: No; 0: Yes
###
branch=${1}

existed_in_remote=$(git ls-remote --heads origin ${branch})

if [[ -z ${existed_in_remote} ]]; then
    echo 1
else
    echo 0
fi