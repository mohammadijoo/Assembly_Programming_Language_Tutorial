bits 64
default rel
global _start

section .text
_start:
    ; Demo: a tiny leaf function can be as small as a couple of instructions.
    ; SysV AMD64: args in RDI, RSI, RDX, RCX, R8, R9 ; return in RAX.

    mov rdi, 10
    mov rsi, 20
    mov rdx, 30
    call add3                 ; RAX = 10 + 20 + 30

    ; Linux x86-64 syscall: exit(status)
    mov rdi, rax              ; status (low 8 bits are used by the OS)
    mov rax, 60               ; SYS_exit
    syscall

; add3(a,b,c) = a+b+c
add3:
    ; Leaf function: no stack frame, no spills, no saves.
    lea rax, [rdi + rsi]
    add rax, rdx
    ret
