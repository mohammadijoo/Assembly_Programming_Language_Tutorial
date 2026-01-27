; Chapter 5 - Lesson 8, Exercise Solution 1
; Branchless clamp64 via CMOVcc.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

%define N 32

section .data
lo      dq -100
hi      dq  100
invals  dq -500, -101, -100, -99, -1, 0, 1, 77, 100, 101, 400, -250, 33, -33, 999, -999
        dq  5, 6, 7, 8, 9, -9, -8, -7, 42, -42, 123, -123, 88, -88, 1000, -1000

section .bss
outbuf  resq N

section .text
clamp64:
    mov rax, rdi
    cmp rax, rsi
    cmovl rax, rsi
    cmp rax, rdx
    cmovg rax, rdx
    ret

_start:
    xor rcx, rcx
.loop:
    cmp rcx, N
    je  .done
    mov rdi, [invals + rcx*8]
    mov rsi, [lo]
    mov rdx, [hi]
    call clamp64
    mov [outbuf + rcx*8], rax
    inc rcx
    jmp .loop
.done:
    mov eax, 60
    xor edi, edi
    syscall
