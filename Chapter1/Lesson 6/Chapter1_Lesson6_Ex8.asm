nasm -f elf64 -g -F dwarf -o build/exit0.o src/exit0.asm
ld -o build/exit0 build/exit0.o
./build/exit0
echo $?
