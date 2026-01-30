; Chapter7_Lesson6_Ex6.asm
; Software prefetch demo: sum bytes with/without PREFETCHT0.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define BUF_BYTES (16*1024*1024)
%define PREF_DIST 256

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; init buffer
    lea rdi, [rel buf]
    mov rcx, BUF_BYTES
    mov al, 1
.init:
    mov [rdi], al
    inc al
    inc rdi
    dec rcx
    jnz .init

    ; ---- no prefetch ----
    call mem_tsc
    mov r12, rax

    xor rax, rax
    lea rbx, [rel buf]
    xor rsi, rsi
.nopf:
    add al, [rbx + rsi]
    inc rsi
    cmp rsi, BUF_BYTES
    jb  .nopf

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg0]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- with prefetch ----
    call mem_tsc
    mov r12, rax

    xor rax, rax
    lea rbx, [rel buf]
    xor rsi, rsi
.pf:
    prefetcht0 [rbx + rsi + PREF_DIST]
    add al, [rbx + rsi]
    inc rsi
    cmp rsi, BUF_BYTES
    jb  .pf

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
title: db "Ex6: PREFETCHT0 effect on linear scan",10,0
msg0:  db "cycles(no prefetch): ",0
msg1:  db "cycles(with prefetch): ",0

section .bss
buf: resb BUF_BYTES
