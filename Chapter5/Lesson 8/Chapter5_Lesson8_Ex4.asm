; Chapter 5 - Lesson 8, Example 4
; Loop form and predictability: bottom-tested (DEC/JNZ) has an easy pattern.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

section .data
n       dq 1000000
a       dq 1
b       dq 2
sum1    dq 0
sum2    dq 0

section .text
_start:
    mov     rcx, [n]
    xor     rax, rax
.top_test:
    test    rcx, rcx
    je      .done_top
    add     rax, [a]
    add     rax, [b]
    dec     rcx
    jmp     .top_test
.done_top:
    mov     [sum1], rax

    mov     rcx, [n]
    xor     rdx, rdx
    test    rcx, rcx
    je      .done_bottom
.bottom_body:
    add     rdx, [a]
    add     rdx, [b]
    dec     rcx
    jne     .bottom_body
.done_bottom:
    mov     [sum2], rdx

    mov     eax, 60
    xor     edi, edi
    syscall
