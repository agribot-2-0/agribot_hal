#!/usr/bin/env bash

status=''
verbose='false'
init_repositories='true'

function check_for_errors () {
    echo -e "\e[35m$1\e[0m"
    if [[ $1 == *"fatal:"* ]] || [[ $1 == *"error:"* ]]
    then
        echo -e "\e[31m[ERROR]: Some error occurred while updating subrepositories:"
        echo -e "$1\e[0m"
        exit 1
    fi
    if [[ $1 == *"Changes not staged for commit:"* ]]
    then
        echo -e "\e[31m[ERROR]: Changes in repository $2 not staged for commit."
        echo -e "Fix problem manually and rerun the script, so that the repository"
        echo -e "can be updated properly.\e[0m"
        cd ..
        continue
    fi
}

while getopts 'v' opt;
do
    case "${opt}" in
    v) echo -e "\e[32mRun script in verbose mode.\e[0m"
       verbose='true' ;;
    *) echo -e "\e[31mUnknown flag. Exiting script...\e[0m"
       exit 1;;
    esac
done

status=$(git pull origin master 2>&1)
for D in */ ;
do
    cd $D
    file_cnt=$(echo -n "$(ls)" | grep -c '^')
    if [[ $file_cnt != 0 ]]
    then
        init_repositories='false'
    fi
    cd ..
done

if [ $init_repositories == 'true' ]
then
    echo "Initializing repositories..."
    status="$status $(git submodule update --init --recursive 2>&1)"
else
    echo "Updating repositories..."
    status="$status $(git submodule update --remote --recursive 2>&1)"
fi

check_for_errors "$status"
if [ $verbose == 'true' ]
then
    echo "$status"
fi
status=''

for D in */ ;
do
    echo -e "\e[4mEntering subrepository $D\e[0m"
    cd "$D"
    status=$(git status 2>&1)
    check_for_errors "$status" $D #TODO: if true -> continue
    exit 1
    statusb=$(git checkout master 2>&1)
    statusc=$(git remote update origin --prune 2>&1)
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
    statusd=$(git checkout $branch 2>&1)
    statuse=$(git pull origin $branch 2>&1)
    if [[ $statusa$statusb$statusc$statusd$statuse == *"error"* ]]
    then
        echo -e "\e[31m[ERROR]: Some error occurred in $D."
        echo "$status\e[0m"
        cd ..
        continue
    fi
    if [ $verbose == 'true' ]
    then
        echo "$status"
    fi
    echo -e "Latest commit:" "\e[32m$commit\e[0m" from branch: "\e[32m$branch\e[0m"
    cd ..
done
