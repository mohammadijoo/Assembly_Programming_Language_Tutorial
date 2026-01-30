; Chapter7_Lesson6_Ex12.asm
; Exercise Solution 2:
; Software-pipelined prefetch + unrolling for a bandwidth-bound sum.
; Goal: demonstrate loop structure that keeps multiple cache misses in flight.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define BUF_BYTES (64*1024*1024)
%define UNROLL    8
%define PREF_DIST 512

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
    inc rdi
    inc al
    dec rcx
    jnz .init

    call mem_tsc
    mov r12, rax

    lea rsi, [rel buf]
    lea rdi, [rel buf + BUF_BYTES]
    xor rax, rax

.loop:
    ; prefetch a block ahead (hide miss latency)
    prefetcht0 [rsi + PREF_DIST]

    ; unrolled body: UNROLL loads
    add al, [rsi + 0]
    add al, [rsi + 1]
    add al, [rsi + 2]
    add al, [rsi + 3]
    add al, [rsi + 4]
    add al, [rsi + 5]
    add al, [rsi + 6]
    add al, [rsi + 7]

    add rsi, UNROLL
    cmp rsi, rdi
    jb .loop

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
title: db "Ex12 (solution): unrolled sum with prefetch (pipeline misses)",10,0
msg:   db "cycles(sum scan): ",0

section .bss
buf: resb BUF_BYTES
