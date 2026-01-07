; x86-64 NASM: branch-based conditional (ARM-style thinking).
; If x == 0 then y=1 else y=2; return y.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, 0          ; x
    xor     ebx, ebx        ; y

    test    eax, eax
    jz      .x_is_zero

    mov     ebx, 2
    jmp     .done

.x_is_zero:
    mov     ebx, 1

.done:
    mov     edi, ebx
    mov     eax, SYS_exit
    syscall
