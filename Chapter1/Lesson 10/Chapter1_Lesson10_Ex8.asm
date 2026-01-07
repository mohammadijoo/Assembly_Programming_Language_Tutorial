# Assemble (NASM) to ELF64 object
nasm -f elf64 hello.asm -o hello.o

# Link
ld hello.o -o hello

# Disassemble .text (Intel syntax)
objdump -d -Mintel hello

# Dump raw bytes of .text
objdump -s -j .text hello.o

# Disassemble raw binary if you produced flat output
# (Example: ndisasm -b 64 file.bin)
ndisasm -b 64 file.bin
