; Terminal commands (shown in an asm-styled block for consistent highlighting)

nasm -f elf64 hello.asm -o hello.o
ld -o hello hello.o
./hello
