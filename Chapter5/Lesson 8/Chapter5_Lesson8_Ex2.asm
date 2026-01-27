; Chapter 5 - Lesson 8, Example 2
; Branchless sum/count using SETcc + mask (no conditional branch in the hot loop).
; Target: Linux x86-64, NASM

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
    xor     rcx, rcx
    xor     rsi, rsi
.loop:
    mov     rax, [arr + rsi*8]
    test    rax, rax
    setg    dl
    movzx   rdx, dl
    neg     rdx               ; 0 or -1 mask
    mov     r8, rax
    and     r8, rdx
    add     rbx, r8
    sub     rcx, rdx          ; +1 when mask=-1
    inc     rsi
    cmp     rsi, N
    jne     .loop

    mov     [sum], rbx
    mov     [cnt], rcx

    mov     eax, 60
    xor     edi, edi
    syscall
