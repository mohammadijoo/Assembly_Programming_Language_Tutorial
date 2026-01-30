; Chapter7_Lesson6_Ex4.asm
; Page-touch benchmark: touch 1 byte per 4KiB page.
; Prints cycles for first pass (cold pages) and second pass (warm).

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define REGION_BYTES (64*1024*1024)
%define STRIDE       4096

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; ---- First pass ----
    call mem_tsc
    mov r12, rax

    lea rbx, [rel region]
    xor rsi, rsi
.pass1:
    ; write forces allocation/zero-fill + page table work
    mov byte [rbx + rsi], 1
    add rsi, STRIDE
    cmp rsi, REGION_BYTES
    jb  .pass1

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg1]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- Second pass ----
    call mem_tsc
    mov r12, rax

    lea rbx, [rel region]
    xor rsi, rsi
.pass2:
    add byte [rbx + rsi], 1
    add rsi, STRIDE
    cmp rsi, REGION_BYTES
    jb  .pass2

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg2]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
title: db "Ex4: first-touch vs warm-touch across pages",10,0
msg1:  db "cycles(first pass): ",0
msg2:  db "cycles(second pass): ",0

section .bss
region: resb REGION_BYTES
