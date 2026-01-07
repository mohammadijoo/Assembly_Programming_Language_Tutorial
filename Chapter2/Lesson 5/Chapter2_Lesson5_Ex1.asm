; Chapter 2 - Lesson 5 - Ex1 (Intel syntax, NASM/YASM)
; long add3(long a, long b, long c) => a + b + c
bits 64
default rel

section .text
global add3

add3:
    ; SysV AMD64 ABI: a=%rdi, b=%rsi, c=%rdx
    lea rax, [rdi + rsi]
    add rax, rdx
    ret
