; Chapter 5 - Lesson 8, Example 8
; Microbench: branchy vs branchless (random vs biased signs).
; Target: Linux x86-64, NASM
;
; Build:
;   nasm -felf64 Chapter5_Lesson8_Ex8.asm -o ex8.o
;   ld ex8.o -o ex8
; Run:
;   perf stat -e cycles,instructions,branches,branch-misses ./ex8
;
; Requires: Chapter5_Lesson8_Ex7.asm in the same directory.

BITS 64
DEFAULT REL

%include "Chapter5_Lesson8_Ex7.asm"

%define N 65536

global _start

section .bss
arr_rand    resq N
arr_bias    resq N

section .data
seed        dq 1
cycles_br_rand   dq 0
cycles_bl_rand   dq 0
cycles_br_bias   dq 0
cycles_bl_bias   dq 0
sum_sink    dq 0
cnt_sink    dq 0

section .text
fill_rand:
    test rcx, rcx
    je   .done
.loop:
    imul rax, rax, 6364136223846793005
    add  rax, 1
    mov  [rdi], rax
    add  rdi, 8
    dec  rcx
    jne  .loop
.done:
    ret

fill_bias:
    xor r8d, r8d
    test rcx, rcx
    je   .done
.loop:
    imul rax, rax, 6364136223846793005
    add  rax, 1
    mov  r9, rax
    and  r9, 0x7FFFFFFFFFFFFFFF
    mov  r10, r8
    and  r10, 15
    jnz  .store
    or   r9, 0x8000000000000000
.store:
    mov  [rdi], r9
    add  rdi, 8
    inc  r8
    dec  rcx
    jne  .loop
.done:
    ret

branchy_sum_count:
    xor rax, rax
    xor rdx, rdx
    xor rcx, rcx
.loop:
    cmp rcx, rsi
    je  .done
    mov r8, [rdi + rcx*8]
    test r8, r8
    jle .skip
    add rax, r8
    inc rdx
.skip:
    inc rcx
    jmp .loop
.done:
    ret

branchless_sum_count:
    xor rax, rax
    xor rdx, rdx
    xor rcx, rcx
.loop:
    cmp rcx, rsi
    je  .done
    mov r8, [rdi + rcx*8]
    test r8, r8
    setg r9b
    movzx r9, r9b
    add  rdx, r9
    neg  r9
    and  r8, r9
    add  rax, r8
    inc  rcx
    jmp  .loop
.done:
    ret

_start:
    mov rax, [seed]
    lea rdi, [arr_rand]
    mov rcx, N
    call fill_rand

    lea rdi, [arr_bias]
    mov rcx, N
    call fill_bias

    TSC_START r12
    lea rdi, [arr_rand]
    mov rsi, N
    call branchy_sum_count
    TSC_STOP r13
    sub r13, r12
    mov [cycles_br_rand], r13
    mov [sum_sink], rax
    mov [cnt_sink], rdx

    TSC_START r12
    lea rdi, [arr_rand]
    mov rsi, N
    call branchless_sum_count
    TSC_STOP r13
    sub r13, r12
    mov [cycles_bl_rand], r13
    mov [sum_sink], rax
    mov [cnt_sink], rdx

    TSC_START r12
    lea rdi, [arr_bias]
    mov rsi, N
    call branchy_sum_count
    TSC_STOP r13
    sub r13, r12
    mov [cycles_br_bias], r13
    mov [sum_sink], rax
    mov [cnt_sink], rdx

    TSC_START r12
    lea rdi, [arr_bias]
    mov rsi, N
    call branchless_sum_count
    TSC_STOP r13
    sub r13, r12
    mov [cycles_bl_bias], r13
    mov [sum_sink], rax
    mov [cnt_sink], rdx

    mov eax, 60
    xor edi, edi
    syscall
