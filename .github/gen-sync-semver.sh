#!/bin/bash

# Identifier of what triggered this synchronization.
#   Can be: [fd_rel, ppb_rel, hotfix_rel]
syncReason=$1
releaseSuffix="_rel"

branchName=$(git rev-parse --abbrev-ref HEAD)

# Branch name regexes
developRegex="^([a-zA-Z0-9]+)\/develop$"
releaseRegex="^([a-zA-Z0-9]+)\/release\/([0-9]+)\.([0-9]+)\.0$"


if [[ "$syncReason" == "" ]]; then
  echo "unknown"

elif [[ $branchName =~ $developRegex ]]; then
  division=${BASH_REMATCH[1]}

  lastDevTag=$(git tag -l "*$division.alpha*" --sort=-v:refname | head -n 1)
  alphaTagRegex="^([0-9]+)\.([0-9]+)\.0-$division.alpha\.([0-9]+)(\+([0-9]+))?$"

  if [[ $lastDevTag =~ $alphaTagRegex ]]; then
    alphaMajor=${BASH_REMATCH[1]}
    alphaMinor=${BASH_REMATCH[2]}
    devIntegrations=${BASH_REMATCH[3]}
    buildIntegrations=${BASH_REMATCH[5]}
    newCommits=$(git rev-list $lastDevTag..HEAD --count)
  fi

  if [[ ("$syncReason" == "hotfix$releaseSuffix") ]]; then
    echo "$alphaMajor.$alphaMinor.0-$division.alpha.$(($devIntegrations+$newCommits))+$(($buildIntegrations+1))"

  elif [[ "$syncReason" == "$division$releaseSuffix" ]]; then
    lastProdTag=$(git tag -l --sort=-v:refname | grep -E "^([0-9])\.([0-9]+)\.([0-9]+)$" | head -n 1)
    prodRegex="^([0-9]+)\.([0-9]+)\.([0-9]+)$"

    if [[ $lastProdTag =~ $prodRegex ]]; then
      prodMajor=${BASH_REMATCH[1]}
      prodMinor=${BASH_REMATCH[2]}

      #echo "$prodMajor.$(($prodMinor+1)).0-$division.alpha.$newCommits"
      echo "$prodMajor.$(($prodMinor+1)).0-$division.alpha.0"
    fi

  elif [[ "$syncReason" != "$division$releaseSuffix" ]]; then
    lastProdTag=$(git tag -l --sort=-v:refname | grep -E "^([0-9])\.([0-9]+)\.([0-9]+)$" | head -n 1)
    prodRegex="^([0-9]+)\.([0-9]+)\.([0-9]+)$"

    if [[ $lastProdTag =~ $prodRegex ]]; then
      prodMajor=${BASH_REMATCH[1]}
      prodMinor=${BASH_REMATCH[2]}

      echo "$prodMajor.$(($prodMinor+1)).0-$division.alpha.$(($devIntegrations+$newCommits))"
    fi

  else
    echo "unknown"
  fi

elif [[ $branchName =~ $releaseRegex ]]; then

  division=${BASH_REMATCH[1]}
  major=${BASH_REMATCH[2]}
  minor=${BASH_REMATCH[3]}
  lastReleaseTag=$(git tag -l "$major.$minor.0-$division.beta*" --sort=-v:refname | head -n 1)
  betaTagRegex="^$major.$minor.0-$division.beta\.([0-9]+)(\+([0-9]+))?$"

  if [[ $lastReleaseTag =~ $betaTagRegex ]]; then
    releaseIntegrations=${BASH_REMATCH[1]}
    releaseFixes=${BASH_REMATCH[3]}
    newCommits=$(git rev-list $lastReleaseTag..HEAD --count)
  fi

  if [[ ("$syncReason" == "hotfix$releaseSuffix") ]]; then
    echo "$major.$minor.0-$division.beta.$releaseIntegrations+$(($releaseFixes + $newCommits + 1))"

  else
    echo "unknown"
    
  fi

else
  echo "unknown"
fi
