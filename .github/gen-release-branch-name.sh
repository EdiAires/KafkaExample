#!/bin/bash

# The release type for this name generation. It can be due to a Major, Minor or Patch release
# For release type Major or Minor this script must be run from Develop branches.
#     This is needed to calculate which division triggered the release process
releaseType=$1


if [[ "$releaseType" == "major" ]]; then
  division=$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f 1)
  lastAlphaTag=$(git tag -l "*$division.alpha*" --sort=-v:refname | head -n 1)
  regex="^([0-9]+)\.([0-9]+)\.([0-9]+)-$division.alpha\.([0-9]+)(\+([0-9]+))?$" # Note: major and minor regex are different

  if [[ $lastAlphaTag =~ $regex ]]; then
    major=${BASH_REMATCH[1]}
    branchName="$(($major+1)).0.0"
    echo "$branchName"
  fi

elif [[ "$releaseType" == "minor" ]]; then
  division=$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f 1)
  lastAlphaTag=$(git tag -l "*$division.alpha*" --sort=-v:refname | head -n 1)
  regex="^([0-9]+\.[0-9]+\.[0-9]+)-$division.alpha\.([0-9]+)(\+([0-9]+))?$" # Note: major and minor regex are different

  if [[ $lastAlphaTag =~ $regex ]]; then
    base=${BASH_REMATCH[1]}
    branchName="$base"
    echo "$branchName"
  fi

elif [[ "$releaseType" == "patch" ]]; then
  lastProdTag=$(git tag -l --sort=-v:refname | grep -E "^([0-9])\.([0-9]+)\.([0-9]+)$" | head -n 1)
  regex="^([0-9]+)\.([0-9]+)\.([0-9]+)$"

  if [[ $lastProdTag =~ $regex ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    patch=${BASH_REMATCH[3]}
    branchName="$major.$minor.$(($patch+1))"
    echo "$branchName"
  fi

else
  echo "unknown"
fi
