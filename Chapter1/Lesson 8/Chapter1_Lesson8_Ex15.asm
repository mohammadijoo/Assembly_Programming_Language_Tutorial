# nasm -f elf64 a.asm -o a.o
# nasm -f elf64 b.asm -o b.o
# ld -o conflict a.o b.o
# Expected: "multiple definition of `util`" (exact text varies)
