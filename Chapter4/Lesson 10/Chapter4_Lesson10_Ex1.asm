bits 64
default rel

global _start

section .data
msg db "LEA computes an effective address (EA); it does not read memory.", 10
len equ $ - msg

section .text
_start:
    ; rsi = &msg using RIP-relative addressing (PIE-friendly)
    lea rsi, [rel msg]
    mov edx, len              ; write length
    mov eax, 1                ; SYS_write
    mov edi, 1                ; fd=stdout
    syscall

    mov eax, 60               ; SYS_exit
    xor edi, edi              ; status=0
    syscall
