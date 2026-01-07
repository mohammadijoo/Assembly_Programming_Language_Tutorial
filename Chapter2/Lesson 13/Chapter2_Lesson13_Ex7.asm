; x86-64 NASM: max(a,b) using signed comparison and conditional jump.
; Return max as exit code (low 8 bits).

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, -7         ; a
    mov     ebx, 5          ; b

    cmp     eax, ebx
    jge     .a_is_max
    mov     eax, ebx
.a_is_max:
    ; return low byte of EAX
    mov     edi, eax
    mov     eax, SYS_exit
    syscall
