# nasm -f elf64 mul_add.asm -o mul_add.o
# nasm -f elf64 checksum.asm -o checksum.o
# ar rcs libmath.a mul_add.o checksum.o
# nasm -f elf64 main_lib.asm -o main_lib.o
# ld -o app main_lib.o -L. -lmath
