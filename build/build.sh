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
    export PKG_CONFIG_PATH=${install_dir}/lib/pkgconfig:${PKG_CONFIG_PATH}
    export PATH=${install_dir}/bin/:${PATH}
    
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
                  -DLLVM_ENABLE_RTTI=on \
                  -DCMAKE_INSTALL_PREFIX=${install_dir} \
                  -DCMAKE_BUILD_TYPE=${buildtype} \
                  -DBUILD_SHARED_LIBS=on \
                  -DLLVM_BUILD_LLVM_DYLIB=off \
                  -DLLVM_ENABLE_PROJECTS="clang" \
                  -DLLVM_TARGET_ARCH="riscv32" \
                  -DLLVM_TARGETS_TO_BUILD="RISCV;X86" \
                  -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-linux-gnu"

        fi
        cmake --build ${build_dir} -j ${build_job_num}
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

function build_qemu
{
    echo "####################################################"
    echo "# Start build QEMU"

    if [ -f ${qemu_dir}/README.rst ]; then

        if [ ! -d ${build_dir} ]; then
            mkdir -p ${build_dir}

            pushd ${build_dir}
                ${qemu_dir}/configure --prefix=${install_dir} --target-list=x86_64-softmmu --enable-kvm
            popd
        fi
        ninja -C ${build_dir} install
        if [ $? -ne 0 ]; then
            echo "build qemu failed and exit"
            exit -1
        fi

    else
        echo "qemu is a illegal repos under this project"
    fi
    echo "# build QEMU done"
    echo "####################################################"

}

# main function
curr_path=${PWD}
curr_pathname=`basename ${PWD}`
cpu_nums=`nproc`
build_job_num=`awk 'BEGIN{printf "%d", '$cpu_nums' * 0.7}'`

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

if [ -f /etc/redhat-release ]; then
    source /opt/rh/devtoolset-9/enable
    source /opt/rh/rh-python38/enable
    export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:${PKG_CONFIG_PATH}
fi

# check current path and build project
case ${curr_pathname} in
    rvgpu)
        echo "Build All projects under rvgpu"
        # build llvm
        llvm_dir=${curr_path}/rvgpu-llvm
        build_dir=${curr_path}/build/rvgpu-llvm
        build_llvm
        # build cmodel
        cmodel_dir=${curr_path}/rvgpu-cmodel
        build_dir=${curr_path}/build/rvgpu-cmodel
        build_cmodel
        # build qemu
        qemu_dir=${curr_path}/qemu
        build_dir=${curr_path}/build/qemu
        build_qemu
        # build mesa
        mesa_dir=${curr_path}/rvgpu-mesa
        build_dir=${curr_path}/build/rvgpu-mesa
        build_mesa
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
