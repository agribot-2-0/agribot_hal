#!/usr/bin/env bash

status=""
verbose="false"
init_repositories="true"
problem_detected="false"

function check_for_errors () {
    if [[ $1 == *"stash"* ]]
    then
        problem_detected="warning"
        echo -e "\e[35m[WARNING]: Some repositories are not staged for commit:"
        echo -e "$1\e[0m"
        return
    fi
    if [[ $1 == *"fatal:"* ]] || [[ $1 == *"error:"* ]]
    then
        problem_detected="error"
        echo -e "\e[31m[ERROR]: Some error occurred:"
        echo -e "$1\e[0m"
        return
    fi
    if [[ $1 == *"Changes not staged for commit:"* ]]
    then
        problem_detected="warning"
        echo -e "\e[35m[WARNING]: Changes in repository $2 not staged for commit."
        echo -e "Fix problem manually and rerun the script, so that the repository"
        echo -e "can be updated properly.\e[0m"
        return
    fi
}

while getopts 'v' opt;
do
    case "${opt}" in
    v) verbose="true" ;;
    *) echo -e "\e[31mUnknown flag. Exiting script...\e[0m"
       exit 1;;
    esac
done

if [ $verbose == "false" ]
then
    echo -e "\e[90mScript run in silent mode. To see git output,\
 run script in verbose mode (-v)\e[0m"
fi

status=$(git pull origin master 2>&1)
for D in */ ;
do
    cd $D
    file_cnt=$(echo -n "$(ls)" | grep -c '^')
    if [[ $file_cnt != 0 ]]
    then
        init_repositories="false"
    fi
    cd ..
done

if [ $init_repositories == "true" ]
then
    echo "Initializing subrepositories..."
    status="$status $(git submodule update --init --recursive 2>&1)"
else
    echo "Updating subrepositories..."
    status="$status $(git submodule update --remote --recursive 2>&1)"
fi

check_for_errors "$status"
if [ $problem_detected == "error" ]
then
    problem_detected="false"
    exit 1
fi
if [ $problem_detected == "warning" ]
then
    problem_detected="false"
fi

if [ $verbose == "true" ]
then
    echo "$status"
fi

for D in */ ;
do
    status=""
    echo -e "\e[4mEntering subrepository $D\e[0m"
    cd $D
    status=$(git status 2>&1)
    # Check if there are changes not staged for commit:
    check_for_errors "$status" $D
    if [[ $problem_detected == "warning" ]] || [[ $problem_detected == "error" ]]
    then
        problem_detected="false"
        cd ..
        continue
    fi
    status="$status $(git checkout master 2>&1)"
    status="$status $(git remote update origin --prune 2>&1)"
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
    status="$status $(git checkout $branch 2>&1)"
    status="$status $(git pull origin $branch 2>&1)"
    # Check for some other errors/fatals:
    check_for_errors "$status" $D
    if [[ $problem_detected == "warning" ]] || [[ $problem_detected == "error" ]]
    then
        problem_detected="false"
        cd ..
        continue
    fi
    if [ $verbose == "true" ]
    then
        echo "$status"
    fi
    echo -e "Latest commit:" "\e[32m$commit\e[0m" from branch: "\e[32m$branch\e[0m"
    cd ..
done
