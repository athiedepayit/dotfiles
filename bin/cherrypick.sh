#!/usr/bin/env bash

# cherry pick commits from dependabot branches
query=$1
commits=$(gh pr list -A 'dependabot[bot]' -S "$query" --json commits|jq -r .[].commits[].oid)
echo "$commits"
echo "Cherry pick these commits?"
read -r -p "y/N " response
if [[ "$response" == "y" ]]; then
    for commit in $commits; do
	git cherry-pick $commit
    done
fi
