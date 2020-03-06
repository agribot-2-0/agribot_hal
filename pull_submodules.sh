#!/bin/bash

git submodule update --init --recursive

for D in */ ;
do
    echo Entering "$D"
    cd "$D"
    git checkout master
    git remote update origin --prune
    commit=$(echo $(git log -1 --all --date-order) | awk -F 'commit | ' '{print $2}')
    branch=$(git branch --contains $commit | cut -c 3-)
    if [ -z $branch ]
    then
	branch=$(git branch -a --all --contains $commit | cut -c 18-)
    fi
    echo "--- > Latest commit:" "$commit" from branch: "$branch"
    git checkout $branch
    git pull origin $branch
    cd ..
done
