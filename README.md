https://wiki.osdev.org/Main_Page

Step 1 : Update WSL
sudo apt update && sudo apt upgrade

Step 2 : Compiler & Assembly
sudo apt install build-essential nasm gcc-multilib

Step 3 : QEMU
sudo apt install qemu-system-x86

Check-up
nasm --version
gcc --version
qemu-system-i386 --version

Compilation
nasm -f bin boot.asm -o boot.bin

Start
qemu-system-i386 boot.bin