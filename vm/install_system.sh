export PATH=/home/zac/git/rvgpu/install/bin:${PATH}
export LD_LIBRARY_PATH=/home/zac/git/rvgpu/install/lib

# Create a Virtual Disk
# qemu-img create -f qcow2 ubuntu2204.img 100G

# boot qemu with a iso file
qemu-system-x86_64 -enable-kvm -m 16G -smp 8 -boot once=d -drive file=./ubuntu2204.img -cdrom ubuntu-22.04.3-desktop-amd64.iso
