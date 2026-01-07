; x86-64 (NASM): RIP-relative access to global
default rel

section .data
g_counter: dq 123

section .text
global read_counter
read_counter:
    mov rax, [g_counter]    ; encoded as RIP-relative in position-independent form
    ret
