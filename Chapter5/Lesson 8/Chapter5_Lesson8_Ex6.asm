; Chapter 5 - Lesson 8, Example 6
; ABS branchy vs branchless (bit trick).
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

section .data
vals    dq  -7,  3, -1, 0,  5, -9, 12, -2
nvals   dq  8
sum_br  dq  0
sum_bl  dq  0

section .text
abs_branchy:
    mov     rax, rdi
    test    rax, rax
    jge     .done
    neg     rax
.done:
    ret

abs_branchless:
    mov     rax, rdi
    mov     rdx, rax
    sar     rdx, 63
    xor     rax, rdx
    sub     rax, rdx
    ret

_start:
    xor     rbx, rbx
    xor     rcx, rcx
.loop1:
    cmp     rcx, [nvals]
    je      .done1
    mov     rdi, [vals + rcx*8]
    call    abs_branchy
    add     rbx, rax
    inc     rcx
    jmp     .loop1
.done1:
    mov     [sum_br], rbx

    xor     rbx, rbx
    xor     rcx, rcx
.loop2:
    cmp     rcx, [nvals]
    je      .done2
    mov     rdi, [vals + rcx*8]
    call    abs_branchless
    add     rbx, rax
    inc     rcx
    jmp     .loop2
.done2:
    mov     [sum_bl], rbx

    mov     eax, 60
    xor     edi, edi
    syscall
