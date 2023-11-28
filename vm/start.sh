image_path=/home/pub/vm/ubuntu2204_zac.img

absolute_path=$(readlink -f "$0")
curr_dir=$(dirname "$absolute_path")

rvgpu_top_path=${curr_dir}/../../

export PATH=${rvgpu_top_path}/install/bin:${PATH}
export LD_LIBRARY_PATH=${rvgpu_top_path}/install/lib

# start qemu use from image
qemu-system-x86_64 -enable-kvm -m 16G -smp 8 -hda ${image_path} --device rvgpu,id=rvg0 --device rvgpu,id=rvg1 -vnc :50
