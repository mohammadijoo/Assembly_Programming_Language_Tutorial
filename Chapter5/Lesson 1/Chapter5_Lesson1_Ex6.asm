BITS 64
default rel
global _start

; Pointer selection via TEST + CMOV:
;   msg = (x == 0) ? msg_zero : msg_nz

section .data
x dq 0

msg_zero db "x is zero", 10
msg_zero_len equ $-msg_zero

msg_nz db "x is non-zero", 10
msg_nz_len equ $-msg_nz

section .text
_start:
    mov rax, [x]
    test rax, rax                   ; sets ZF if rax == 0

    lea rsi, [msg_zero]
    mov rdx, msg_zero_len
    lea rcx, [msg_nz]
    mov r8,  msg_nz_len

    ; If ZF==0 (x != 0), select non-zero message.
    cmovnz rsi, rcx
    cmovnz rdx, r8

    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
