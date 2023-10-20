#!/bin/bash

rvgpu_b="main"
gvm_b="main"
llvm_b="rvgpu"
cmodel_b="main"
cudatb_b="main"
tools_b="main"
docs_b="main"

print_result() {
    printf "| %-15s | %-20s | %-20s |\n" "$1" "$2" "$3"
}

is_sync_to_server() {
    local_branch=$1
    remote_branch=$2

    if [ ${local_branch} != "${remote_branch}" ]; then
        return 1
    fi

    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse FETCH_HEAD)

    if [ "$local_commit" == "$remote_commit" ]; then
        return 0
    else
        return 1
    fi
}

check_repos() {
    pushd $1 > /dev/null
        curr_repo=`basename ${PWD}`
        local_branch=$(git rev-parse --abbrev-ref HEAD)

        is_sync_to_server ${local_branch} $2
        if [ $? -eq 0 ]; then
            print_result ${curr_repo} ${local_branch} OK
        else
            print_result ${curr_repo} ${local_branch} "Not Sync"
        fi
    popd     > /dev/null
}

fetch_remote() {
    pushd $1 > /dev/null
        curr_repo=`basename ${PWD}`
        remote_branch=$2

        git fetch origin "${remote_branch}" > /dev/null 2>&1
    popd     > /dev/null
}

fetch_remote_repos() {
    fetch_remote ./              ${rvgpu_b}
    fetch_remote gvm             ${gvm_b}
    fetch_remote rvgpu-llvm      ${llvm_b}
    fetch_remote rvgpu-cmodel    ${cmodel_b}
    fetch_remote cuda_testbench  ${cudatb_b}
    fetch_remote tools           ${tools_b}
    fetch_remote docs            ${docs_b}
}

fetch_remote_repos

echo "+-----------------+----------------------+----------------------+"
echo "| repository      | current branch       | compare to remote    |"
echo "+-----------------+----------------------+----------------------+"

check_repos ./              ${rvgpu_b}
check_repos gvm             ${gvm_b}
check_repos rvgpu-llvm      ${llvm_b}
check_repos rvgpu-cmodel    ${cmodel_b}
check_repos cuda_testbench  ${cudatb_b}
check_repos tools           ${tools_b}
check_repos docs            ${docs_b}

echo "+-----------------+----------------------+----------------------+"
