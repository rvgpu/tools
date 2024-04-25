# run this file use: docker image build -t rvgpu/rvgpu:latest .

FROM ubuntu:22.04
LABEL maintainer="qihangkong@outlook.com"

ENV DEBIAN_FRONTEND=noninteractive  

RUN apt-get update && apt-get install -y build-essential git cmake python3 python3-pip pkg-config libdrm-dev libgtest-dev ninja-build wget g++-12 && rm -rf /var/lib/apt/lists/*

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && dpkg -i cuda-keyring_1.0-1_all.deb && rm cuda-keyring_1.0-1_all.deb  

RUN apt-get update && apt-get install -y --no-install-recommends cuda && rm -rf /var/lib/apt/lists/*  

# WORKDIR /rvgpu
