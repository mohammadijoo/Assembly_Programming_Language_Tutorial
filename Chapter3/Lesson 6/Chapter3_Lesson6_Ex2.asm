BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

section .rodata
msg0: db "Example 1: same bits, different meaning (byte x = 0xF0)",10
msg0_len: equ $-msg0

msg_u: db "Unsigned (zero-extended to 64-bit): ",0
msg_u_len: equ $-msg_u-1

msg_s: db "Signed (sign-extended to 64-bit):   ",0
msg_s_len: equ $-msg_s-1

msg_cmp: db "Compare x with 0x10:",10
msg_cmp_len: equ $-msg_cmp

msg_u_gt: db "  Unsigned jump (JA) takes: x is above 0x10",10
msg_u_gt_len: equ $-msg_u_gt

msg_u_ng: db "  Unsigned jump (JA) does not take",10
msg_u_ng_len: equ $-msg_u_ng

msg_s_lt: db "  Signed jump (JL) takes: x is less than 0x10",10
msg_s_lt_len: equ $-msg_s_lt

msg_s_nl: db "  Signed jump (JL) does not take",10
msg_s_nl_len: equ $-msg_s_nl

section .data
x: db 0xF0

section .text
_start:
    WRITE msg0, msg0_len

    WRITE msg_u, msg_u_len
    movzx eax, byte [x]
    mov rax, rax
    call write_hex64

    WRITE msg_s, msg_s_len
    movsx rax, byte [x]
    call write_hex64

    WRITE msg_cmp, msg_cmp_len

    ; Unsigned decision
    mov al, [x]
    cmp al, 0x10
    ja .u_gt
    WRITE msg_u_ng, msg_u_ng_len
    jmp .after_u
.u_gt:
    WRITE msg_u_gt, msg_u_gt_len
.after_u:

    ; Signed decision
    mov al, [x]
    cmp al, 0x10
    jl .s_lt
    WRITE msg_s_nl, msg_s_nl_len
    jmp .done
.s_lt:
    WRITE msg_s_lt, msg_s_lt_len

.done:
    EXIT 0
