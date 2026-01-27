BITS 64
default rel
global _start

section .data
a dq -25
b dq  11

msg_a db "max(a,b) selected: a", 10
msg_a_len equ $-msg_a

msg_b db "max(a,b) selected: b", 10
msg_b_len equ $-msg_b

section .text
_start:
    mov rax, [a]
    mov rbx, [b]

    ; Branchless selection of message using CMOVcc.
    ; cmov* does not modify flags, so it is safe after CMP.
    cmp rax, rbx                    ; signed compare a vs b

    lea rsi, [msg_a]
    mov rdx, msg_a_len
    lea rcx, [msg_b]
    mov r8,  msg_b_len

    ; If a < b, choose msg_b; otherwise keep msg_a.
    cmovl rsi, rcx
    cmovl rdx, r8

    mov rax, 1                      ; sys_write
    mov rdi, 1
    syscall

    mov rax, 60                     ; sys_exit
    xor rdi, rdi
    syscall
