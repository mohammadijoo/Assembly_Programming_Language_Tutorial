; Chapter7_Lesson6_Ex7.asm
; Ordinary stores vs non-temporal stores (MOVNTDQ) for streaming writes.
; Prints cycles for filling a large buffer twice.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define BUF_BYTES (64*1024*1024)

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; ---- ordinary stores (write-allocate into caches) ----
    call mem_tsc
    mov r12, rax

    lea rdi, [rel buf]
    mov rcx, BUF_BYTES/8
    mov rax, 0x1122334455667788
.stq:
    mov [rdi], rax
    add rdi, 8
    dec rcx
    jnz .stq

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg0]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---- non-temporal stores (streaming) ----
    call mem_tsc
    mov r12, rax

    pxor xmm0, xmm0
    lea rdi, [rel buf]
    mov rcx, BUF_BYTES/16
.nt:
    movntdq [rdi], xmm0
    add rdi, 16
    dec rcx
    jnz .nt
    sfence

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
title: db "Ex7: cached stores vs MOVNTDQ streaming stores",10,0
msg0:  db "cycles(ordinary stores): ",0
msg1:  db "cycles(non-temporal stores): ",0

section .bss
align 16
buf: resb BUF_BYTES
