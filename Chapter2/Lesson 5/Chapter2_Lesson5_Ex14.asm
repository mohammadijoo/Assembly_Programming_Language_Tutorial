; Chapter 2 - Lesson 5 - Ex14 (Intel syntax, NASM/YASM)
; unsigned long popcount64(unsigned long x) using the Brian Kernighan loop.
bits 64
default rel

section .text
global popcount64

popcount64:
    xor eax, eax            ; count = 0
.loop:
    test rdi, rdi
    jz .done

    lea rcx, [rdi - 1]
    and rdi, rcx            ; x &= (x-1)
    inc eax
    jmp .loop

.done:
    ret
