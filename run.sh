#!/bin/bash

set -e

if [ -z "$WERCKER_GOBUMP_GITHUB_PULL_REQUEST_GITHUB_TOKEN" ]; then
    fail 'you must set github_token option'
fi

github_token="$WERCKER_GOBUMP_GITHUB_PULL_REQUEST_GITHUB_TOKEN"

label_pattern_major="$WERCKER_GOBUMP_GITHUB_PULL_REQUEST_LABEL_PATTERN_MAJOR"
label_pattern_minor="$WERCKER_GOBUMP_GITHUB_PULL_REQUEST_LABEL_PATTERN_MINOR"
changed_files_pattern="$WERCKER_GOBUMP_GITHUB_PULL_REQUEST_CHANGED_FILES_PATTERN"

# Install tools
go get github.com/motemen/gobump/cmd/gobump
curl -s http://stedolan.github.io/jq/download/linux64/jq -o ./jq
chmod +x ./jq

# Set up Git user
git config --global user.email 'pleasemailus@wercker.com'
git config --global user.name  'werckerbot'

# Bump version according to the Pull Request just merged
pr_number=$(git show --pretty=%s | sed -n 's/^Merge pull request #\([0-9]\{1,\}\) .*/\1/p')

if [ -n "$pr_number" ]; then
  if [ -z "$changed_files_pattern" ] || ( git diff --name-only HEAD~1 | grep -q -i -E "$changed_files_pattern" ); then
    labels=$(curl -s -H "Authorization: token $github_token" \
        "https://api.github.com/repos/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/issues/$pr_number/labels" | ./jq -r 'map(.name) | join("\n")')

    command='patch'
    if [ -n "$label_pattern_major" ] && ( echo "$labels" | grep -q -i -E "$label_pattern_major" ) then
      command='major'
    elif [ -n "$label_pattern_minor" ]  && ( echo "$labels" | grep -q -i -E "$label_pattern_minor" ) then
      command='minor'
    fi

    new_version=$(gobump $command -w -v | ./jq -r '.[]')

    if ! git diff --exit-code ./*.go; then
      git add ./*.go
      git commit -m "bump version to $new_version"$'\n\n'"$WERCKER_DEPLOY_URL"
      git push "https://$github_token@github.com/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY" HEAD:master

      export GOBUMP_NEW_VERSION="$new_version"
    fi
  else
    info "no files matching '$changed_files_pattern' changed"
  fi
else
  info 'no pull request merged, will not bump version'
fi
