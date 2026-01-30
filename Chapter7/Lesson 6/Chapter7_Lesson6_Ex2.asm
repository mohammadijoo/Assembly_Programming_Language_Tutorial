; Chapter7_Lesson6_Ex2.asm
; Register vs memory read loop: a tiny sanity microbenchmark.
; Prints two cycle counts (hex): (1) register-only loop, (2) linear memory loads.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define ITERS  50000000

section .text
_start:
    ; ---------- Warm up ----------
    lea rdi, [rel msg]
    call mem_write_cstr

    ; ---------- (1) Register-only loop ----------
    call mem_tsc
    mov r12, rax

    xor rax, rax
    mov rcx, ITERS
.reg_loop:
    add rax, 1
    dec rcx
    jnz .reg_loop

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_reg]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; ---------- Prepare buffer ----------
    lea rdi, [rel buf]
    mov rcx, BUF_QWORDS
    xor rax, rax
.fill:
    mov [rdi], rax
    add rdi, 8
    add rax, 1
    dec rcx
    jnz .fill

    ; ---------- (2) Linear memory loads ----------
    call mem_tsc
    mov r12, rax

    xor rax, rax
    lea rbx, [rel buf]
    mov rcx, ITERS
.mem_loop:
    ; read one qword (wrap around buffer)
    mov rdx, rcx
    and rdx, (BUF_QWORDS-1)
    mov rdx, [rbx + rdx*8]
    add rax, rdx
    dec rcx
    jnz .mem_loop

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg_mem]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    ; exit(0)
    xor rdi, rdi
    mov rax, SYS_exit
    syscall

section .rodata
msg:     db "Ex2: reg loop vs memory load loop",10,0
msg_reg: db "cycles(reg loop): ",0
msg_mem: db "cycles(mem loads): ",0

section .bss
; keep power-of-two qword count for cheap masking above
%define BUF_QWORDS  8192
buf: resq BUF_QWORDS
