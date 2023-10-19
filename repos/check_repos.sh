#!/bin/bash

branch_rvgpu="main"
branch_gvm="main"

is_sync_to_server() {
    local_branch=$1
    remote_branch=$2

    if [ ${local_branch} != ${remote_branch} ]; then
        return 1
    fi

    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse $remote_branch)

    if [ "$local_commit" == "$remote_commit" ]; then
        return 0
    else
        return 1
    fi
}

print_result() {
    printf "| %-15s | %-20s | %-20s |\n" "$1" "$2" "$3"
}

check_repos() {
    pushd $1 > /dev/null
        curr_repo=`basename ${PWD}`
        local_branch=$(git rev-parse --abbrev-ref HEAD)
        remote_branch=$2

        is_sync_to_server ${local_branch} ${remote_branch}
        if [ $? -eq 0 ]; then
            print_result ${curr_repo} ${local_branch} OK
        else
            print_result ${curr_repo} ${local_branch} "Not Sync"
        fi
    popd     > /dev/null
}

echo "+-----------------+----------------------+----------------------+"
echo "| repository      | current branch       | compare to server    |"
echo "+-----------------+----------------------+----------------------+"

check_repos ./              main
check_repos gvm             main
check_repos rvgpu-llvm      rvgpu
check_repos cuda_testbench  main
check_repos tools           main
check_repos docs            main

echo "+-----------------+----------------------+----------------------+"
