#! /bin/bash
# 

repos=(  'cuda_testbench' 'docs' 'gvm'  'kmod-drv' 'qemu'  'rvgpu-cmodel' 'rvgpu-llvm' 'rvgpu-mesa' 'tools')
branchs=('main'           'main' 'main' 'main'     'rvgpu' 'main'         'zac1'       'rvgpu'      'main')

sync_to_github() {
    repo=${1}
    branch=${2}
    url="https://github.com/rvgpu/${repo}.git"
    echo "Sync ${repo} to ${url} branch:${branch}"
    pushd ${repo}
        remotes=$(git remote -v)
        if echo "${remotes}" | grep -q "github"; then
            git push github ${branch}
        else
            git remote add github ${url}
            git push github ${branch}
        fi
    popd
}

for i in "${!repos[@]}"; do
    reponame="${repos[$i]}"
    repobranch="${branchs[$i]}"
    sync_to_github ${reponame} ${repobranch}
done
