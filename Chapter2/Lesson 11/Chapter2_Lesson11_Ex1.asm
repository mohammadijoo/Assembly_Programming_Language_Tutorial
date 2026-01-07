; NASM x86-64, Linux
; Minimal skeleton emphasizing: global + section + label

BITS 64
global _start

section .text
_start:
    ; exit(0)
    mov     eax, 60         ; SYS_exit
    xor     edi, edi        ; status = 0
    syscall
