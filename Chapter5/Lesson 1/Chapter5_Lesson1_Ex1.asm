BITS 64
default rel
global _start

section .data
a dq 7
b dq 12

msg_lt db "a < b (signed)", 10
msg_lt_len equ $-msg_lt

msg_ge db "a >= b (signed)", 10
msg_ge_len equ $-msg_ge

section .text
_start:
    mov rax, [a]
    mov rbx, [b]

    ; CMP performs (rax - rbx) conceptually and sets flags (ZF/SF/OF/CF/...).
    cmp rax, rbx
    jl .lt

.ge:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; fd = stdout
    mov rsi, msg_ge
    mov rdx, msg_ge_len
    syscall
    jmp .exit

.lt:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_lt
    mov rdx, msg_lt_len
    syscall

.exit:
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; status = 0
    syscall
