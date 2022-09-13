#!/bin/bash

current_working_directory=$(pwd)
temp_dir=$(mktemp -d -t git-XXXXXX)

echo $temp_dir

for index in $(jq 'keys | .[]' git-externals.json); do
    clone_url=$(jq -r ".[$index].repoCloneUrl" git-externals.json)
    branch=$(jq -r ".[$index].branch" git-externals.json)
    commit=$(jq -r ".[$index].commit" git-externals.json)
    folders=$(jq -r ".[$index].folders" git-externals.json)

    clone_path="$temp_dir/$index"

    if [ $branch != null ]; then
        echo $clone_path
        
        git clone $clone_url --branch $branch --single-branch $clone_path
    elif [ $commit != null ]; then
        # Initilize the Git directory
        git init $clone_path
        
        # Move working path to Git directory
        cd $clone_path
        
        # Add remote URL
        git remote add origin $clone_url

        # Fetch specified commit
        git fetch origin $commit

        # Reset working directory to commit
        git reset --hard FETCH_HEAD
    else
        echo "You must specify either a branch or a commit" 1>&2
        exit 1
    fi

    for index in $(jq 'keys | .[]' <<< "$folders" ); do
        source=$(jq -r ".[$index].source" <<< "$folders")
        destination=$(jq -r ".[$index].destination" <<< "$folders")

        echo $clone_path

        copy_source="$clone_path$source"
        copy_destination="$current_working_directory$destination"

        echo $copy_source
        echo $copy_destination

        cp -r $copy_source $copy_destination
    done
done

cd $current_working_directory
