; Chapter7_Lesson6_Ex9.asm
; Cache-hit vs cache-miss timing using CLFLUSH on one cache line.
; This is a *measurement* example for performance intuition.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; warm: read once
    mov rax, [rel line]

    ; measure hit
    call mem_tsc
    mov r12, rax
    mov rax, [rel line]
    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_hit]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; flush then measure miss (approx)
    clflush [rel line]
    mfence

    call mem_tsc
    mov r12, rax
    mov rax, [rel line]
    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_miss]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
title:    db "Ex9: CLFLUSH to approximate a cold load",10,0
msg_hit:  db "cycles(load hit-ish): ",0
msg_miss: db "cycles(load miss-ish): ",0

section .bss
align 64
line: resb 64
