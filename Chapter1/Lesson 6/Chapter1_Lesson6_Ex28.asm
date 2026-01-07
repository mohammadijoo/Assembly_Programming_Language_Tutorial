nasm -f elf64 -o build/exit0_nasm.o src/exit0_nasm.asm
ld -o build/exit0_nasm build/exit0_nasm.o
