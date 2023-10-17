#! /usr/bin/env bash

# main function
curr_path=${PWD}
curr_dirname=`basename ${PWD}`

cpu_nums=`nproc`
build_job_num=`awk 'BEGIN{printf "%d", '$cpu_nums' * 1.0}'`

if [ $curr_dirname == "rvgpu" ]; then
    echo "Run cuda regression test under: ${curr_path}"
    echo "Build project:"
    ./tools/build/build.sh --prefix=./regression/install --builddir=./regression/build --release

    # on centos7, need to link libcudart.so.12 to libcudart.so.11.0
    pushd ./regression/install/lib
        if [ ! -f libcudart.so.12 ]; then
            ln -s libcudart.so.11.0 libcudart.so.12
        fi
    popd

    export PATH=${curr_path}/regression/install/bin:${PATH}
    export LD_LIBRARY_PATH=${curr_path}/regression/install/lib

    which clang++

    mkdir -p ${curr_path}/regression/tb
    pushd ${curr_path}/regression/tb
        cmake ${curr_path}/cuda_testbench
        cmake --build .
        echo $LD_LIBRARY_PATH
        make test
    popd
fi
