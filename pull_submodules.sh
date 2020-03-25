#!/bin/bash

git pull origin master
git submodule update --init --recursive

for D in */ ;
do
    echo -e "\e[4mEntering folder $D\e[0m"
    cd "$D"
    status=$(git status)
    if [[ $status == *"Changes not staged for commit:"* ]]
    then
        echo -e "\e[31m[ERROR]: Changes in repository $D not staged for commit."
        echo -e "Fix problem manually and rerun the script, so that the repository"
        echo -e "can be updated properly.\e[0m"
        cd ..
        continue
    fi
    git checkout master
    git remote update origin --prune
    commit=$(echo $(git log -1 --all --date-order) | awk -F 'commit | ' '{print $2}')
    branch=$(git branch --contains $commit | cut -c 3-)
    if [ -z $branch ]
    then
        branch=$(git branch -a --all --contains $commit | cut -c 18-)
    fi
    if [[ $branch == *"HEAD -> origin/"* ]]
    then
        branch=$(echo $branch | cut -c 23-)
    fi
    git checkout $branch
    git pull origin $branch
    echo -e "Latest commit:" "\e[32m$commit\e[0m" from branch: "\e[32m$branch\e[0m"
    cd ..
done
