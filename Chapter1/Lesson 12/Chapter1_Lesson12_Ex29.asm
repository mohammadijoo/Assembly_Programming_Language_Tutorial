; leaf_ops.asm
; Assemble SysV:  nasm -DABI_SYSV  -f elf64 leaf_ops.asm -o leaf_ops.o
; Assemble Win64: nasm -DABI_WIN64 -f win64 leaf_ops.asm -o leaf_ops.obj

%include "abi_adapter.inc"

section .text
DEF_LEAF u64_add
    mov rax, ARG0
    add rax, ARG1
    ret

DEF_LEAF u64_xor
    mov rax, ARG0
    xor rax, ARG1
    ret