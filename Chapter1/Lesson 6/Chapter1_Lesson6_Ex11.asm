nasm -f elf64 -g -F dwarf -o build/hello_syscall.o src/hello_syscall.asm
ld -o build/hello_syscall build/hello_syscall.o
./build/hello_syscall
