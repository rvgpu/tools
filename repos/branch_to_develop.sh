#! /usr/bin/env bash

function checkout_to_branch
{
    projname=$1
    branchname=$2
    pushd $1
        curr_branch=`git branch | grep '\*' | cut -d ' ' -f 2`
        echo ${curr_branch}
        if [ ${curr_branch}!="$branchname" ]; then
            git checkout ${branchname}
            # git checkout -b $branchname origin/$branchname
        fi
    popd
}

# checkout_to_branch tools main
checkout_to_branch docs main
checkout_to_branch qemu rvgpu
checkout_to_branch rvgpu-cmodel main
checkout_to_branch rvgpu-llvm rvgpu
checkout_to_branch rvgpu-mesa rvgpu 
