; Chapter7_Lesson6_Ex14.asm
; Exercise Solution 4:
; Two-phase "page warm-up" benchmark:
;   Phase A: touch 1 byte per page (commit + page tables)
;   Phase B: immediately repeat (should hit TLB + resident pages)
; Prints both cycle counts and the ratio (rough, integer).

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define REGION_BYTES (256*1024*1024)
%define STRIDE       4096

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; mmap anonymous
    xor rdi, rdi
    mov rsi, REGION_BYTES
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_PRIVATE | MAP_ANON
    mov r8, -1
    xor r9, r9
    mov rax, SYS_mmap
    syscall
    cmp rax, -4095
    jae .fail
    mov r15, rax

    ; ---- phase A ----
    call mem_tsc
    mov r12, rax
    xor rsi, rsi
.A:
    mov byte [r15 + rsi], 1
    add rsi, STRIDE
    cmp rsi, REGION_BYTES
    jb  .A
    call mem_tsc
    sub rax, r12
    mov r13, rax

    lea rdi, [rel msgA]
    call mem_write_cstr
    mov rdi, r13
    call mem_write_hex64

    ; ---- phase B ----
    call mem_tsc
    mov r12, rax
    xor rsi, rsi
.B:
    add byte [r15 + rsi], 1
    add rsi, STRIDE
    cmp rsi, REGION_BYTES
    jb  .B
    call mem_tsc
    sub rax, r12
    mov r14, rax

    lea rdi, [rel msgB]
    call mem_write_cstr
    mov rdi, r14
    call mem_write_hex64

    ; integer ratio approx: (A_cycles * 100) / B_cycles
    lea rdi, [rel msgR]
    call mem_write_cstr
    mov rax, r13
    mov rcx, 100
    mul rcx               ; rdx:rax = A*100
    div r14               ; rax = ratio
    mov rdi, rax
    call mem_write_hex64

    ; munmap
    mov rdi, r15
    mov rsi, REGION_BYTES
    mov rax, SYS_munmap
    syscall

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

.fail:
    lea rdi, [rel msgFail]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64
    mov rdi, 1
    mov rax, SYS_exit
    syscall

section .rodata
title:   db "Ex14 (solution): page warm-up ratio (A/B)",10,0
msgA:    db "cycles(phase A first touch): ",0
msgB:    db "cycles(phase B warm touch): ",0
msgR:    db "ratio_hex((A*100)/B): ",0
msgFail: db "mmap failed, rax = ",0
