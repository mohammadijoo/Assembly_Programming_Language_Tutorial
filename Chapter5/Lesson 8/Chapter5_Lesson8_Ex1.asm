; Chapter 5 - Lesson 8, Example 1
; Branchy (data-dependent) loop: intentionally unpredictable (~50% taken).
; Target: Linux x86-64, NASM
;
; Build:
;   nasm -felf64 Chapter5_Lesson8_Ex1.asm -o ex1.o
;   ld ex1.o -o ex1
; Run:
;   ./ex1
; Suggested profiling:
;   perf stat -e branches,branch-misses ./ex1

BITS 64
DEFAULT REL

%define N 65536

global _start

section .bss
arr     resq N

section .data
seed    dq 1
sum     dq 0
cnt     dq 0

section .text
_start:
    mov     rcx, N
    lea     rdi, [arr]
    mov     rax, [seed]
.fill:
    imul    rax, rax, 6364136223846793005
    add     rax, 1
    mov     [rdi], rax
    add     rdi, 8
    loop    .fill

    xor     rbx, rbx
    xor     rdx, rdx
    xor     rsi, rsi
.loop:
    mov     rax, [arr + rsi*8]
    test    rax, rax
    jle     .skip
    add     rbx, rax
    inc     rdx
.skip:
    inc     rsi
    cmp     rsi, N
    jne     .loop

    mov     [sum], rbx
    mov     [cnt], rdx

    mov     eax, 60
    xor     edi, edi
    syscall
