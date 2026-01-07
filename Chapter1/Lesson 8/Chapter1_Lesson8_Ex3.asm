# Example (Linux ELF workflow)
# nasm -f elf64 -g -F dwarf hello_puts.asm -o hello_puts.o
# nm -C hello_puts.o
# readelf -S hello_puts.o
# readelf -r hello_puts.o
# objdump -drwC hello_puts.o
