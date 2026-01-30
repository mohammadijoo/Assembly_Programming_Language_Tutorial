; Chapter7_Lesson6_Ex11.asm
; Exercise Solution 1:
; Multi-stream scan: increase the number of independent streams to stress cache/TLB resources.
; This is a controlled way to see bandwidth vs latency vs front-end overhead tradeoffs.
;
; Tweak STREAMS (4..32) and STRIDE to explore behavior.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define BUF_BYTES (64*1024*1024)
%define STRIDE    4096
%define STREAMS   16

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; init buffer (touch pages)
    lea rdi, [rel buf]
    mov rcx, BUF_BYTES/8
    mov rax, 1
.init:
    mov [rdi], rax
    add rdi, 8
    add rax, 1
    dec rcx
    jnz .init

    ; compute STREAMS base pointers (buf + i*STRIDE)
    lea rbx, [rel buf]
    lea rdi, [rel ptrs]
    xor r8, r8
.make_ptrs:
    lea rax, [rbx + r8*STRIDE]
    mov [rdi + r8*8], rax
    inc r8
    cmp r8, STREAMS
    jb .make_ptrs

    call mem_tsc
    mov r12, rax

    ; Iterate across buffer in steps of STREAMS*STRIDE
    xor r9, r9
.outer:
    ; for each stream, load one byte then advance pointer by STREAMS*STRIDE
    xor r8, r8
.inner:
    lea r11, [rel ptrs]
    mov r10, [r11 + r8*8]
    add al, [r10]
    add r10, STREAMS*STRIDE
    mov [r11 + r8*8], r10
    inc r8
    cmp r8, STREAMS
    jb .inner

    add r9, STREAMS*STRIDE
    cmp r9, BUF_BYTES
    jb  .outer

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
title: db "Ex11 (solution): multi-stream scan (tune STREAMS/STRIDE)",10,0
msg:   db "cycles(total scan): ",0

section .bss
buf:  resb BUF_BYTES
ptrs: resq STREAMS
