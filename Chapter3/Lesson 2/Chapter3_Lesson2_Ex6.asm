; Chapter 3 - Lesson 2 (Example 6)
; Compile-time constants and computed sizes (equ, times, $)

BITS 64
default rel

%define N 16                ; preprocessor-style constant (text substitution)

section .data
msg         db "Initialized table[0..15] with its indices.", 10
msg_len     equ $ - msg

section .bss
table       resb N          ; uninitialized array of N bytes

section .text
global _start

_start:
    ; table[i] = i for i=0..N-1
    xor     ebx, ebx
.fill:
    mov     byte [table + rbx], bl
    inc     rbx
    cmp     rbx, N
    jne     .fill

    ; print message
    mov     eax, 1          ; SYS_write
    mov     edi, 1
    lea     rsi, [msg]
    mov     edx, msg_len
    syscall

    mov     eax, 60         ; SYS_exit
    xor     edi, edi
    syscall
