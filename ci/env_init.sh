#! /usr/bin/env bash

# Tools to install
function install_tools
{
    sudo apt install git cmake meson pkg-config
}

# Thirdpart devlib
function install install_devlibs
{
    # mesa3d dependens
    sudo apt install expat bison byacc flex
    sudo apt install libdrm-dev libgtest-dev
    sudo apt install libx11-dev libxext-dev libxfixes-dev libxcb-glx0-dev libxcb-shm0-dev libx11-xcb-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev libxshmfence-dev libxxf86vm-dev libxrandr-dev
    

    # Qemu dependens
    sudo apt install libglib2.0-dev libpixman-1-dev
}

install_tools
install_devlibs
