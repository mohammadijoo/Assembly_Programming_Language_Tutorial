nasm -f elf64 -g -F dwarf -o build/sections.o src/sections.asm
ld -o build/sections build/sections.o

# Entry point (e_entry) and section listing:
readelf -h build/sections
readelf -S build/sections

# Confirm symbol placement and addresses:
nm -n build/sections
