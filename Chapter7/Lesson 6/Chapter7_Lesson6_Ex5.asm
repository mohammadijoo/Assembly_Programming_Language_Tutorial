; Chapter7_Lesson6_Ex5.asm
; Alignment and SIMD loads: movdqa (aligned) vs movdqu (unaligned).
; NOTE: movdqa requires 16-byte alignment; we only use it on aligned data.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; ---- aligned load ----
    call mem_tsc
    mov r12, rax

    mov rax, 0
    mov rcx, 20000000
.aligned:
    movdqa xmm0, [rel aligned16]
    paddq xmm0, xmm0
    dec rcx
    jnz .aligned

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_a]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- unaligned load (safe) ----
    call mem_tsc
    mov r12, rax

    mov rax, 0
    mov rcx, 20000000
.unaligned:
    movdqu xmm0, [rel unaligned16]
    paddq xmm0, xmm0
    dec rcx
    jnz .unaligned

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_u]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
title: db "Ex5: aligned vs unaligned SIMD loads",10,0
msg_a: db "cycles(movdqa aligned): ",0
msg_u: db "cycles(movdqu unaligned): ",0

align 16
aligned16:   dq 0x0102030405060708, 0x1112131415161718
unaligned16: db 0x99
             dq 0x0102030405060708, 0x1112131415161718
