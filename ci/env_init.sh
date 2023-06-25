#! /usr/bin/env bash

# Tools to install
function install_tools_on_ubuntu
{
    sudo apt install git cmake meson pkg-config

    # mesa3d dependens
    sudo apt install expat bison byacc flex
    sudo apt install libdrm-dev libgtest-dev
    sudo apt install libx11-dev libxext-dev libxfixes-dev libxcb-glx0-dev libxcb-shm0-dev libx11-xcb-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev libxshmfence-dev libxxf86vm-dev libxrandr-dev

    # Qemu dependens
    sudo apt install libglib2.0-dev libpixman-1-dev

}

function install_tools_on_centos
{
    sudo yum install centos-release-scl
    sudo yum makecache
    sudo yum install devtoolset-9 rh-python38
    sudo yum install git ninja-build expat
    sudo yum install openssl-devel gtest-devel glib2-devel pixman-devel expat-devel libXext-devel libXfixes-devel libxshmfence-devel libXxf86vm-devel libXrandr-devel 

    # source /opt/rh/rh-python38/enable
    # pip3.8 install meson==1.1.0 --user
    # pip3.8 install mako==1.2.4 --user
}

function install_cmake
{
    pushd ${build_dir}
        if [ ! -d CMake ]; then
            git clone https://github.com/Kitware/CMake.git -b v3.26.4
        fi
        echo "Build CMake"
        pushd CMake
            ./configure

            sudo gmake install
        popd

    popd
}

function install_libdrm
{
    pushd ${build_dir}
        if [ ! -d drm ]; then
            git clone https://gitlab.freedesktop.org/mesa/drm.git -b libdrm-2.4.115
        fi

        pushd drm
            meson build
            sudo ninja -C build install
        popd
    popd
}

function build_and_install_from_sourcecodes
{
    echo "build and install from source codes"
    # install_cmake
    install_libdrm
}

build_dir=${PWD}/build/thirdparty
mkdir -p ${build_dir}

if [ -f /etc/redhat-release ]; then
    echo "System is CentOS"
    install_tools_on_centos
    build_and_install_from_sourcecodes
elif [ -f /etc/lsb-release]; then
    echo "System is Ubuntu"
    install_tools_on_ubuntu
else
    echo "System Unknowed"
fi
