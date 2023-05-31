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
#  rvgpu:           构建所有的rvgpu子项目, 默认将安装到./install路径下
#  rvgpu-llvm:      构建rvgpu-llvm子项目，默认将安装到./install路径下
#  rvgpu-mesa:      构建rvgpu-mesa子项目，默认将安装到./install路径下
#  rvgpu-cmodel:    构建rvgpu-cmodel子项目，默认将安装到./install路径下

function print_help
{
    echo "Usage:" 
    echo "  /tools/build/build.sh [options]"
    echo "      --prefix dir : 指定安装路径，默认是./install"
    echo "      --release    : 指定构建为release模式，默认是debug"
}

function build_cmodel
{   
    echo "####################################################"
    echo "# Start build rvgsim"
    if [ -f ${cmodel_dir}/README.md ]; then
        if [ ! -d ${build_dir} ]; then
            mkdir -p ${build_dir} 
            cmake -B ${build_dir} ${cmodel_dir} -DCMAKE_INSTALL_PREFIX=${install_dir} -DCMAKE_BUILD_TYPE=${buildtype}
        fi
        cmake --build ${build_dir}
        if [ $? -ne 0 ]; then
            echo "build rvgpu-sim failed and exit"
            exit -1
        fi

        cmake --install ${build_dir}
    else
        echo "rvgpu-cmodel is a illegal repos under this project"
    fi
    echo "# build rvgsim done"
    echo "####################################################"
}

function build_mesa
{   
    echo "####################################################"
    echo "# Start build mesa"
    
    if [ -f ${mesa_dir}/README.md ]; then
        if [ ! -d ${build_dir} ]; then
            meson ${build_dir} ${mesa_dir} \
                -Dprefix=${install_dir} \
                -Dgallium-drivers=swrast  \
                -Dvulkan-drivers=rvgpu,swrast \
                -Dplatforms=x11 \
                -Dglx=dri \
                -Dbuildtype=${buildtype} \
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
                  -DCMAKE_BUILD_TYPE=${buildtype} \
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
buildtype=debug

## Parse Options
OPTIONS=`getopt -o h --long help,release,prefix: -n 'example.bash' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -h|--help) 
            print_help
            # print help information only, then exit with 0
            exit 0
            ;;
        --release)
            buildtype=release
            shift 1 ;;
        --prefix) 
            install_dir=$2
            shift 2 ;;
        --) 
            shift
            break;;
        *) 
            print_help
            exit 0
            ;;
    esac
done

echo "Prams info"
echo "build type:     ${buildtype}"
echo "install prefix: ${install_dir}"

# check current path and build project
case ${curr_pathname} in
    rvgpu)
        echo "Build All projects under rvgpu"
        # build llvm
        llvm_dir=${curr_path}/rvgpu-llvm
        build_dir=${curr_path}/build/rvgpu-llvm
        build_llvm
        # build mesa
        mesa_dir=${curr_path}/rvgpu-mesa
        build_dir=${curr_path}/build/rvgpu-mesa
        build_mesa
        # build cmodel
        cmodel_dir=${curr_path}/rvgpu-cmodel
        build_dir=${curr_path}/build/rvgpu-cmodel
        build_cmodel
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
        cmodel_dir=${curr_path}
        build_dir=${curr_path}/build
        build_cmodel
        ;;
    *)
        echo "Error project path"
esac
