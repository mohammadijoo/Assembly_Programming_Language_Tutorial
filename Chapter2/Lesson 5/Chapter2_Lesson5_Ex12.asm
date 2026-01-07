; Chapter 2 - Lesson 5 - Ex12 (Intel syntax, NASM/YASM)
; long muladd10(long a, long b) => a*10 + b
bits 64
default rel

section .text
global muladd10

muladd10:
    imul rax, rdi, 10   ; 3-operand form: RAX = RDI * 10
    add  rax, rsi
    ret
