# Example build (Linux ELF)
# nasm -f elf64 -g -F dwarf math64.asm -o math64.o
# nasm -f elf64 -g -F dwarf main64.asm -o main64.o
# ld -o prog main64.o math64.o
# ./prog ; echo $?
