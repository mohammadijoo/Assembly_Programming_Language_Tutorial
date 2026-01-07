\
; Chapter2_Lesson6_Ex10.asm
; NASM: external symbols + relocations by calling libc's puts.
;
; Build (Linux, SysV AMD64):
;   nasm -f elf64 -g -F dwarf Chapter2_Lesson6_Ex10.asm -o ex10.o
;   gcc -no-pie -g ex10.o -o ex10
;   ./ex10
;
; Notes:
; - The assembler emits relocation entries for `puts` and (depending on model)
;   possibly for `hello`.
; - The linker resolves `puts` to the shared library symbol and may route calls
;   through the PLT in dynamically linked executables.

BITS 64
default rel

extern puts
global main

section .text
main:
    ; puts(hello)
    lea rdi, [hello]
    xor eax, eax            ; SysV ABI: AL=0 for varargs call-safety
    call puts

    xor eax, eax
    ret

section .rodata
hello: db "Hello from NASM: calling libc puts via external symbol.", 0
