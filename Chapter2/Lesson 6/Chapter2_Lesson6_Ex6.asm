\
; Chapter2_Lesson6_Ex6.asm
; NASM: using %include to share constants and data between files.
;
; Build:
;   nasm -f elf64 -g -F dwarf Chapter2_Lesson6_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6

BITS 64
default rel

%include "Chapter2_Lesson6_Ex7.asm"

section .text
global _start
_start:
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [msg]
    mov edx, msg_len
    syscall

    mov eax, SYS_exit
    xor edi, edi
    syscall
