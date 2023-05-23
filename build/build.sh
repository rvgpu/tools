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
#  rvgpu:       构建所有的rvgpu子项目, 默认将安装到./install路径下
#  rvgpu-llvm:  构建rvgpu-llvm子项目，默认将安装到./install路径下
#  rvgpu-mesa:  构建rvgpu-mesa子项目，默认将安装到./install路径下

function build_mesa
{   
    echo "####################################################"
    echo "# Start build mesa"
    
    if [ -f ${mesa_dir}/README.md ]; then
        if [ ! -d ${build_dir} ]; then
            meson ${build_dir} ${mesa_dir} \
                -Dprefix=${install_dir} \
                -Dgallium-drivers=  \
                -Dvulkan-drivers=rvgpu \
                -Dplatforms=x11 \
                -Dglx=disabled \
                -Dbuildtype=debug \
                -Dlibdir=lib
        fi
        ninja -C ${build_dir} install

        if [ $? -ne 0 ]; then
            echo "build rvgpu-mesa failed and exit"
            exit -1
        fi
    else
        echo "rvgpu-mesa is a illegal repos under this project"
    fi
    echo "# build mesa done"
    echo "####################################################"
}

function build_llvm
{
    echo "####################################################"
    echo "# Start build LLVM"

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

install_dir=${curr_path}/install

## Parse Options
OPTIONS=`getopt -o h --long help,prefix: -n 'example.bash' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -h|--help) 
            echo "Usage:" 
            echo "  /tools/build/build.sh [options]"
            echo "      --prefix dir : 指定安装路径"
            shift ;;
        --prefix) 
            echo "install prefix: $2" 
            install_dir=$2
            shift 2 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# check current path and build project
case ${curr_pathname} in
    rvgpu)
        echo "TODO build all"
        ;;
    rvgpu-llvm)
        llvm_dir=${curr_path}
        build_dir=${curr_path}/build
        build_llvm
        ;;
    rvgpu-mesa)
        mesa_dir=${curr_path}
        build_dir=${curr_path}/build
        build_mesa
        ;;
    rvgpu-cmodel)
        echo "TODO build cmodel"
        ;;
    *)
        echo "Error project path"
esac
