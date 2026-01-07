; File B: extern a data symbol and read it (no printing; use exit code for quick check).
; Build:
;   nasm -felf64 Chapter2_Lesson11_Ex12.asm -o ex12.o
;   nasm -felf64 Chapter2_Lesson11_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o ex12.o

BITS 64
global _start
extern shared_value

SYS_exit equ 60

section .text
_start:
    mov     rax, [rel shared_value]
    ; Return low byte as exit code
    mov     edi, eax
    mov     eax, SYS_exit
    syscall
