; File B of a two-file project: import a symbol with extern and call it.
; Build (example):
;   nasm -felf64 Chapter2_Lesson11_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o ex5.o
; Run:
;   ./ex6 ; echo $?

BITS 64
global _start
extern add42

SYS_exit equ 60

section .text
_start:
    call    add42         ; rax = 42
    mov     edi, eax      ; exit status = low 32 bits
    mov     eax, SYS_exit
    syscall
