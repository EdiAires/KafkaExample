#!/bin/bash

branchName=$(git rev-parse --abbrev-ref HEAD)

# Branch name regexes
masterRegex="^main|master$"
developRegex="^([a-zA-Z0-9]+)\/develop$"
releaseRegex="^([a-zA-Z0-9]+)\/release\/([0-9]+)\.([0-9]+)\.0$"
hotfixRegex="^hotfix\/([0-9]+)\.([0-9]+)\.([1-9]+)$"
featureRegex="^feature\/([a-zA-Z0-9]+)$"
bugfixRegex="^bugfix\/([a-zA-Z0-9]+)$"

if [[ $branchName =~ $masterRegex ]]; then
  lastProdTag=$(git tag -l --sort=-v:refname | grep -E "^([0-9])\.([0-9]+)\.([0-9]+)$" | head -n 1)
  echo "$lastProdTag"

elif [[ $branchName =~ $developRegex ]]; then
  division=${BASH_REMATCH[1]}
  lastDevelopTag=$(git tag -l "*$division.alpha*" --sort=-v:refname | head -n 1)
  alphaTagRegex="^([0-9]+)\.([0-9]+)\.0-$division.alpha\.([0-9]+)(\+([0-9]+))?$"

  if [[ $lastDevelopTag =~ $alphaTagRegex ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    devIntegrations=${BASH_REMATCH[3]}
    buildIntegrations=${BASH_REMATCH[4]}
    newCommits=$(git rev-list $lastDevelopTag..HEAD --count)

    echo "$major.$minor.0-$division.alpha.$(($devIntegrations + $newCommits))$buildIntegrations"
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

    echo "$major.$minor.0-$division.beta.$releaseIntegrations+$(($releaseFixes + $newCommits))"
  fi

elif [[ $branchName =~ $hotfixRegex ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  lastHotfixTag=$(git tag -l "$major.$minor.$patch-beta*" --sort=-v:refname | head -n 1)
  betaTagRegex="^$major.$minor.$patch-beta.0\+([0-9]+)$"
  
  if [[ $lastHotfixTag =~ $betaTagRegex ]]; then
    hotfixCommits=${BASH_REMATCH[1]}
    newCommits=$(git rev-list $lastHotfixTag..HEAD --count)

    echo "$major.$minor.$patch-beta.0+$(($hotfixCommits + $newCommits))"
  fi

elif [[ $branchName =~ $featureRegex ]]; then
  featureId=${BASH_REMATCH[1]}
  lastFeatureTag=$(git tag -l "*-feature.*+$featureId.*" --sort=-v:refname | head -n 1) # Tag example: 1.2.3-feature.2+featureId.3
  featureTagRegex="^([0-9]+)\.([0-9]+)\.0-feature\.([0-9]+)\+$featureId\.([0-9]+)$"

  if [[ $lastFeatureTag =~ $featureTagRegex ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    devIntegrations=${BASH_REMATCH[3]}
    featureCommits=${BASH_REMATCH[4]}
    newCommits=$(git rev-list $lastFeatureTag..HEAD --count)

    echo "$major.$minor.0-feature.$devIntegrations+$featureId.$(($featureCommits + $newCommits))"
  fi

elif [[ $branchName =~ $bugfixRegex ]]; then
  bugfixId=${BASH_REMATCH[1]}
  lastBugfixTag=$(git tag -l "*-bugfix.*+$bugfixId.*" --sort=-v:refname | head -n 1) # Tag example: 1.2.3-bugfix.2+bugfixId.3
  bugfixTagRegex="^([0-9]+)\.([0-9]+)\.0-bugfix\.([0-9]+)\+$bugfixId\.([0-9]+)$"

  if [[ $lastBugfixTag =~ $bugfixTagRegex ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    devIntegrations=${BASH_REMATCH[3]}
    bugfixCommits=${BASH_REMATCH[4]}
    newCommits=$(git rev-list $lastFeatureTag..HEAD --count)

    echo "$major.$minor.0-bugfix.$devIntegrations+$bugfixId.$(($bugfixCommits + $newCommits))"
  fi

else
  echo "unknown"
fi
