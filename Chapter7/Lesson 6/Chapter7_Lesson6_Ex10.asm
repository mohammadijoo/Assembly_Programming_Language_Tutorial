; Chapter7_Lesson6_Ex10.asm
; First-touch vs warm-touch using mmap'd anonymous memory (no large BSS).
; Demonstrates that allocation is virtual until pages are committed on access.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define REGION_BYTES (128*1024*1024)
%define STRIDE       4096

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; mmap(NULL, REGION_BYTES, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor rdi, rdi
    mov rsi, REGION_BYTES
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_PRIVATE | MAP_ANON
    mov r8, -1
    xor r9, r9
    mov rax, SYS_mmap
    syscall
    cmp rax, -4095
    jae .mmap_fail
    mov r15, rax            ; base

    ; ---- first touch (writes) ----
    call mem_tsc
    mov r12, rax

    xor rsi, rsi
.pass1:
    mov byte [r15 + rsi], 0x7F
    add rsi, STRIDE
    cmp rsi, REGION_BYTES
    jb  .pass1

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg1]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- second touch (reads) ----
    call mem_tsc
    mov r12, rax

    xor rax, rax
    xor rsi, rsi
.pass2:
    add al, [r15 + rsi]
    add rsi, STRIDE
    cmp rsi, REGION_BYTES
    jb  .pass2

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg2]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; munmap(base, REGION_BYTES)
    mov rdi, r15
    mov rsi, REGION_BYTES
    mov rax, SYS_munmap
    syscall

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

.mmap_fail:
    lea rdi, [rel msg_fail]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64
    mov rdi, 1
    mov rax, SYS_exit
    syscall

section .rodata
title:    db "Ex10: mmap first-touch vs warm-touch (page commit)",10,0
msg1:     db "cycles(first touch via mmap): ",0
msg2:     db "cycles(warm scan via mmap): ",0
msg_fail: db "mmap failed, rax = ",0
