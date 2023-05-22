#! /usr/bin/env bash

#
# 此脚本用于构建rvgpu-llvm仓库。
# 
# 使用方法：
#
# build/build.sh 
#
# 此脚本将自动识别当前路径，如果当前路径位于rvgpu下的目录，则将构建当前的项目,
# 项目路径包括如下：
#  rvgpu:       构建所有的rvgpu子项目, 将安装到./install路径下
#  rvgpu-llvm:  构建rvgpu-llvm子项目，将安装到./install路径下


function build_llvm
{
    echo "####################################################"
    echo "# Begin to build LLVM"

    if [ -f ${llvm_dir}/README.md ]; then
        if [ ! -d ${build_dir} ]; then
            mkdir -p ${build_dir}
            cmake -S ${llvm_dir}/llvm \
                  -B ${build_dir} \
                  -G "Ninja" \
                  -DCMAKE_INSTALL_PREFIX=${install_dir} \
                  -DCMAKE_BUILD_TYPE=debug \
                  -DBUILD_SHARED_LIBS=on \
                  -DLLVM_ENABLE_PROJECTS="clang" \
                  -DLLVM_TARGETS_TO_BUILD=RISCV \
                  -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-linux-gnu"

        fi
        cmake --build ${build_dir}
        if [ $? -ne 0 ]; then
            echo "build rvgpu-llvm failed and exit"
            exit -1
        fi

        cmake --install ${build_dir}
    else
        echo "rvgpu-llvm is a illegal repos under this project"
    fi
    echo "# build LLVM done"
    echo "####################################################"
}

# main function
curr_path=${PWD}
curr_pathname=`basename ${PWD}`

if [ $curr_pathname == "rvgpu" ]; then
    echo "Build all project"
    # TODO build_all
elif [ $curr_pathname == "rvgpu-llvm" ]; then
    llvm_dir=${curr_path}
    build_dir=${curr_path}/build
    install_dir=${curr_path}/install
    build_llvm
else
    echo "TODO"
fi
