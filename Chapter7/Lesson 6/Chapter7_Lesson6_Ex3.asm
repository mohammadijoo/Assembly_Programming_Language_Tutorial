; Chapter7_Lesson6_Ex3.asm
; Stride experiment: same total bytes, different strides.
; Measures (a) 64-byte stride (cache-line friendly) vs (b) 4096-byte stride (TLB/page pressure).

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define BUF_BYTES   (8*1024*1024)
%define LINE_STRIDE 64
%define PAGE_STRIDE 4096

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; Fill buffer (touch pages so first-touch cost doesn't dominate)
    lea rdi, [rel buf]
    mov rcx, BUF_BYTES/8
    xor rax, rax
.fill:
    mov [rdi], rax
    add rdi, 8
    add rax, 1
    dec rcx
    jnz .fill

    ; ---- 64-byte stride ----
    call mem_tsc
    mov r12, rax

    xor rax, rax
    lea rbx, [rel buf]
    xor rsi, rsi
.loop_line:
    add al, [rbx + rsi]
    add rsi, LINE_STRIDE
    cmp rsi, BUF_BYTES
    jb  .loop_line

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_line]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- 4096-byte stride ----
    call mem_tsc
    mov r12, rax

    xor rax, rax
    lea rbx, [rel buf]
    xor rsi, rsi
.loop_page:
    add al, [rbx + rsi]
    add rsi, PAGE_STRIDE
    cmp rsi, BUF_BYTES
    jb  .loop_page

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_page]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
title:    db "Ex3: stride effects (64B vs 4KiB)",10,0
msg_line: db "cycles(64B stride): ",0
msg_page: db "cycles(4KiB stride): ",0

section .bss
buf: resb BUF_BYTES
