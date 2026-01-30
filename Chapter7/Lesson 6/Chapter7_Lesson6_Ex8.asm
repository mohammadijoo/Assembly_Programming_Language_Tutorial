; Chapter7_Lesson6_Ex8.asm
; Copy benchmark: REP MOVSB vs a MOVSQ loop.
; Prints cycles for each method.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define NBYTES (64*1024*1024)

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; init src
    lea rdi, [rel src]
    mov rcx, NBYTES/8
    mov rax, 0xA5A5A5A5A5A5A5A5
.init:
    mov [rdi], rax
    add rdi, 8
    dec rcx
    jnz .init

    ; ---- MOVSQ loop ----
    call mem_tsc
    mov r12, rax

    lea rsi, [rel src]
    lea rdi, [rel dst]
    mov rcx, NBYTES/8
.movsq:
    mov rax, [rsi]
    mov [rdi], rax
    add rsi, 8
    add rdi, 8
    dec rcx
    jnz .movsq

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg0]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- REP MOVSB ----
    call mem_tsc
    mov r12, rax

    lea rsi, [rel src]
    lea rdi, [rel dst]
    mov rcx, NBYTES
    rep movsb

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg1]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
title: db "Ex8: REP MOVSB vs scalar copy loop",10,0
msg0:  db "cycles(movsq loop): ",0
msg1:  db "cycles(rep movsb): ",0

section .bss
align 16
src: resb NBYTES
dst: resb NBYTES
