# nasm -f elf64 -g -F dwarf reloc_store.asm -o reloc_store.o
# readelf -r reloc_store.o        # observe relocation against 'msg' for writing into p_msg
# ld -o reloc_store reloc_store.o
# nm -n reloc_store | grep -E "msg|p_msg"
# objdump -dw reloc_store | less  # confirm the store targets p_msg and msg address is resolved
