nasm -I include -f elf64 -g -F dwarf -o build/hello_inc.o src/hello_inc.asm
ld -o build/hello_inc build/hello_inc.o
./build/hello_inc
